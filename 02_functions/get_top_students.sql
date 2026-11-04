-- get_top_students : returns the best active students by GPA as a VARRAY of objects.
-- Uses an explicit cursor + cursor FOR loop. Students without grades are skipped.
-- Usage:  SELECT * FROM TABLE(get_top_students(3));
CREATE OR REPLACE FUNCTION get_top_students (
  p_limit IN PLS_INTEGER DEFAULT 3
) RETURN t_top_students IS
  v_result t_top_students := t_top_students();

  CURSOR c_rank IS
    SELECT student_id,
           first_name || ' ' || last_name AS full_name,
           get_student_gpa(student_id)    AS gpa
      FROM students
     WHERE status = 'ACTIVE'
     ORDER BY 3 DESC NULLS LAST, student_id;
BEGIN
  IF p_limit IS NULL OR p_limit < 1 OR p_limit > 10 THEN
    RAISE_APPLICATION_ERROR(-20065, 'p_limit must be between 1 and 10 (got ' || NVL(TO_CHAR(p_limit),'NULL') || ')');
  END IF;

  FOR r IN c_rank LOOP
    EXIT WHEN v_result.COUNT >= p_limit OR r.gpa IS NULL;
    v_result.EXTEND;
    v_result(v_result.COUNT) := t_student_gpa_obj(r.student_id, r.full_name, r.gpa);
  END LOOP;

  RETURN v_result;
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE <> -20065 THEN
      log_error('get_top_students', SQLCODE, SQLERRM);
    END IF;
    RAISE;
END get_top_students;
/
SHOW ERRORS
