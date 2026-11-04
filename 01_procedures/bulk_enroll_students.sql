-- bulk_enroll_students : enrolls MANY students in one course with a single FORALL.
-- Concepts: nested table parameter (t_id_list), %ROWTYPE record,
--           FORALL ... SAVE EXCEPTIONS, SQL%BULK_EXCEPTIONS, ORA-24381 handling,
--           user-defined exceptions, RAISE_APPLICATION_ERROR.
-- Bad rows (unknown student ID -> ORA-02291, duplicate -> ORA-00001) do NOT stop the good ones.
-- Error codes: -20020 empty list, -20021 course missing, -20022 not enough seats
CREATE OR REPLACE PROCEDURE bulk_enroll_students (
  p_course_id     IN  courses.course_id%TYPE,
  p_student_ids   IN  t_id_list,
  p_success_count OUT NUMBER,
  p_failed_count  OUT NUMBER
) IS
  v_course    courses%ROWTYPE;
  v_used      PLS_INTEGER;
  v_available PLS_INTEGER;
  e_empty_list     EXCEPTION;
  e_not_enough     EXCEPTION;
  e_bulk_errors    EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_bulk_errors, -24381);
  v_err_count PLS_INTEGER;
  v_err_idx   PLS_INTEGER;
  v_err_code  PLS_INTEGER;
BEGIN
  p_success_count := 0;
  p_failed_count  := 0;

  IF p_student_ids IS NULL OR p_student_ids.COUNT = 0 THEN
    RAISE e_empty_list;
  END IF;

  SELECT * INTO v_course FROM courses WHERE course_id = p_course_id;

  SELECT COUNT(*) INTO v_used
    FROM enrollments WHERE course_id = p_course_id AND status <> 'DROPPED';
  v_available := v_course.max_capacity - v_used;
  IF p_student_ids.COUNT > v_available THEN
    RAISE e_not_enough;
  END IF;

  BEGIN
    FORALL i IN 1 .. p_student_ids.COUNT SAVE EXCEPTIONS
      INSERT INTO enrollments (enrollment_id, student_id, course_id, status)
      VALUES (enrollment_seq.NEXTVAL, p_student_ids(i), p_course_id, 'ENROLLED');

    p_success_count := SQL%ROWCOUNT;
  EXCEPTION
    WHEN e_bulk_errors THEN
      v_err_count     := SQL%BULK_EXCEPTIONS.COUNT;
      p_success_count := SQL%ROWCOUNT;          -- rows that DID succeed
      p_failed_count  := v_err_count;
      FOR j IN 1 .. v_err_count LOOP
        v_err_idx  := SQL%BULK_EXCEPTIONS(j).ERROR_INDEX;
        v_err_code := SQL%BULK_EXCEPTIONS(j).ERROR_CODE;
        DBMS_OUTPUT.PUT_LINE('  FAILED student_id=' || p_student_ids(v_err_idx) ||
                             ' -> ORA-' || LPAD(v_err_code, 5, '0') || ': ' || SQLERRM(-v_err_code));
        log_error('bulk_enroll_students', -v_err_code,
                  'student_id=' || p_student_ids(v_err_idx) || ' course_id=' || p_course_id ||
                  ': ' || SQLERRM(-v_err_code));
      END LOOP;
  END;

  DBMS_OUTPUT.PUT_LINE('Bulk enroll into ' || v_course.course_code || ': ' ||
                       p_success_count || ' succeeded, ' || p_failed_count || ' failed');
EXCEPTION
  WHEN e_empty_list THEN
    RAISE_APPLICATION_ERROR(-20020, 'Student list is empty');
  WHEN NO_DATA_FOUND THEN
    log_error('bulk_enroll_students', -20021, 'Course ' || p_course_id || ' not found');
    RAISE_APPLICATION_ERROR(-20021, 'Course ' || p_course_id || ' does not exist');
  WHEN e_not_enough THEN
    log_error('bulk_enroll_students', -20022, 'Not enough seats in course ' || p_course_id);
    RAISE_APPLICATION_ERROR(-20022, 'Only ' || v_available || ' seats left in ' || v_course.course_code ||
                                    ' but ' || p_student_ids.COUNT || ' students requested');
  WHEN OTHERS THEN
    log_error('bulk_enroll_students', SQLCODE, SQLERRM);
    RAISE;
END bulk_enroll_students;
/
SHOW ERRORS
