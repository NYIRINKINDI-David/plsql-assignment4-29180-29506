-- enroll_student : enrolls ONE student in ONE course.
-- Concepts: %ROWTYPE records, implicit cursor (INSERT + SQL%FOUND / SQL%ROWCOUNT),
--           predefined exceptions (NO_DATA_FOUND, DUP_VAL_ON_INDEX),
--           user-defined exceptions, RAISE_APPLICATION_ERROR, OUT parameter.
-- Error codes: -20001 student missing, -20002 student inactive, -20003 course full,
--              -20004 duplicate enrollment, -20005 course missing
CREATE OR REPLACE PROCEDURE enroll_student (
  p_student_id    IN  students.student_id%TYPE,
  p_course_id     IN  courses.course_id%TYPE,
  p_enrollment_id OUT enrollments.enrollment_id%TYPE
) IS
  v_student    students%ROWTYPE;       -- %ROWTYPE record
  v_course     courses%ROWTYPE;        -- %ROWTYPE record
  v_seats_used PLS_INTEGER;
  v_step       VARCHAR2(10) := 'STUDENT';
  e_student_inactive EXCEPTION;        -- user-defined
  e_course_full      EXCEPTION;        -- user-defined
BEGIN
  p_enrollment_id := NULL;

  SELECT * INTO v_student FROM students WHERE student_id = p_student_id;
  IF v_student.status <> 'ACTIVE' THEN
    RAISE e_student_inactive;
  END IF;

  v_step := 'COURSE';
  SELECT * INTO v_course FROM courses WHERE course_id = p_course_id;

  SELECT COUNT(*) INTO v_seats_used
    FROM enrollments
   WHERE course_id = p_course_id AND status <> 'DROPPED';
  IF v_seats_used >= v_course.max_capacity THEN
    RAISE e_course_full;
  END IF;

  INSERT INTO enrollments (enrollment_id, student_id, course_id, status)
  VALUES (enrollment_seq.NEXTVAL, p_student_id, p_course_id, 'ENROLLED')
  RETURNING enrollment_id INTO p_enrollment_id;

  IF SQL%FOUND THEN   -- implicit cursor attributes
    DBMS_OUTPUT.PUT_LINE('Enrolled ' || v_student.first_name || ' ' || v_student.last_name ||
                         ' in ' || v_course.course_code ||
                         ' (enrollment_id=' || p_enrollment_id ||
                         ', rows inserted=' || SQL%ROWCOUNT || ')');
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF v_step = 'STUDENT' THEN
      log_error('enroll_student', -20001, 'Student ' || p_student_id || ' not found');
      RAISE_APPLICATION_ERROR(-20001, 'Student ' || p_student_id || ' does not exist');
    ELSE
      log_error('enroll_student', -20005, 'Course ' || p_course_id || ' not found');
      RAISE_APPLICATION_ERROR(-20005, 'Course ' || p_course_id || ' does not exist');
    END IF;
  WHEN e_student_inactive THEN
    log_error('enroll_student', -20002, 'Student ' || p_student_id || ' is inactive');
    RAISE_APPLICATION_ERROR(-20002, 'Student ' || p_student_id || ' is INACTIVE and cannot enroll');
  WHEN e_course_full THEN
    log_error('enroll_student', -20003, 'Course ' || p_course_id || ' is full');
    RAISE_APPLICATION_ERROR(-20003, 'Course ' || v_course.course_code || ' is full (' ||
                                    v_course.max_capacity || ' seats)');
  WHEN DUP_VAL_ON_INDEX THEN
    log_error('enroll_student', -20004, 'Duplicate enrollment ' || p_student_id || '/' || p_course_id);
    RAISE_APPLICATION_ERROR(-20004, 'Student ' || p_student_id || ' is already enrolled in course ' || p_course_id);
  WHEN OTHERS THEN
    log_error('enroll_student', SQLCODE, SQLERRM);
    RAISE;
END enroll_student;
/
SHOW ERRORS
