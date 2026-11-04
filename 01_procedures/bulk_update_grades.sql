-- bulk_update_grades : adds a curve (+/- points, capped to 0..100) to every graded enrollment of a course.
-- Concepts: BULK COLLECT into nested tables, FORALL UPDATE with SAVE EXCEPTIONS,
--           FORALL INSERT into the audit table, SQL%ROWCOUNT, user-defined exceptions.
-- Error codes: -20010 invalid curve, -20011 no graded rows, -20012 course missing, -20013 bulk DML errors
CREATE OR REPLACE PROCEDURE bulk_update_grades (
  p_course_id    IN  courses.course_id%TYPE,
  p_curve        IN  NUMBER,
  p_rows_updated OUT NUMBER
) IS
  TYPE t_id_tab    IS TABLE OF enrollments.enrollment_id%TYPE;
  TYPE t_grade_tab IS TABLE OF enrollments.grade%TYPE;
  v_ids   t_id_tab;
  v_old   t_grade_tab;
  v_new   t_grade_tab := t_grade_tab();
  v_title courses.title%TYPE;
  e_invalid_curve EXCEPTION;
  e_no_grades     EXCEPTION;
  e_bulk_errors   EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_bulk_errors, -24381);
  v_err_count PLS_INTEGER;
BEGIN
  p_rows_updated := 0;

  IF p_curve IS NULL OR p_curve < -20 OR p_curve > 20 THEN
    RAISE e_invalid_curve;
  END IF;

  SELECT title INTO v_title FROM courses WHERE course_id = p_course_id;

  -- ONE round trip to read all rows (BULK COLLECT); FOR UPDATE locks them
  SELECT enrollment_id, grade
    BULK COLLECT INTO v_ids, v_old
    FROM enrollments
   WHERE course_id = p_course_id
     AND grade IS NOT NULL
     AND status <> 'DROPPED'
   ORDER BY enrollment_id
     FOR UPDATE;

  IF v_ids.COUNT = 0 THEN
    RAISE e_no_grades;
  END IF;

  v_new.EXTEND(v_ids.COUNT);
  FOR i IN 1 .. v_ids.COUNT LOOP
    v_new(i) := LEAST(100, GREATEST(0, v_old(i) + p_curve));
  END LOOP;

  -- ONE round trip to update all rows (FORALL)
  FORALL i IN 1 .. v_ids.COUNT SAVE EXCEPTIONS
    UPDATE enrollments SET grade = v_new(i) WHERE enrollment_id = v_ids(i);
  p_rows_updated := SQL%ROWCOUNT;

  FORALL i IN 1 .. v_ids.COUNT
    INSERT INTO grade_audit (enrollment_id, old_grade, new_grade)
    VALUES (v_ids(i), v_old(i), v_new(i));

  DBMS_OUTPUT.PUT_LINE('Curve ' || p_curve || ' applied to ' || v_title || ': ' ||
                       p_rows_updated || ' grades updated, ' || SQL%ROWCOUNT || ' audit rows written');
EXCEPTION
  WHEN e_invalid_curve THEN
    RAISE_APPLICATION_ERROR(-20010, 'Curve must be between -20 and 20 (got ' || NVL(TO_CHAR(p_curve),'NULL') || ')');
  WHEN e_no_grades THEN
    RAISE_APPLICATION_ERROR(-20011, 'Course ' || p_course_id || ' has no graded enrollments to update');
  WHEN NO_DATA_FOUND THEN
    log_error('bulk_update_grades', -20012, 'Course ' || p_course_id || ' not found');
    RAISE_APPLICATION_ERROR(-20012, 'Course ' || p_course_id || ' does not exist');
  WHEN e_bulk_errors THEN
    v_err_count := SQL%BULK_EXCEPTIONS.COUNT;
    FOR j IN 1 .. v_err_count LOOP
      log_error('bulk_update_grades', -SQL%BULK_EXCEPTIONS(j).ERROR_CODE,
                'enrollment_id=' || v_ids(SQL%BULK_EXCEPTIONS(j).ERROR_INDEX) || ': ' ||
                SQLERRM(-SQL%BULK_EXCEPTIONS(j).ERROR_CODE));
    END LOOP;
    RAISE_APPLICATION_ERROR(-20013, v_err_count || ' grade update(s) failed; see ERROR_LOG. Roll back to undo partial changes.');
  WHEN OTHERS THEN
    log_error('bulk_update_grades', SQLCODE, SQLERRM);
    RAISE;
END bulk_update_grades;
/
SHOW ERRORS
