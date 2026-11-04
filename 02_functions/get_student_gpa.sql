-- get_student_gpa : credit-weighted GPA on a 4.0 scale (A=4,B=3,C=2,D=1,F=0).
-- Only graded, non-dropped enrollments count.
-- Returns NULL (not 0) when the student has no graded courses, so the result is never misleading.
-- Raises -20061 for an unknown student (NO_DATA_FOUND translated).
CREATE OR REPLACE FUNCTION get_student_gpa (
  p_student_id IN students.student_id%TYPE
) RETURN NUMBER IS
  v_id      students.student_id%TYPE;
  v_points  NUMBER;
  v_credits NUMBER;
BEGIN
  SELECT student_id INTO v_id FROM students WHERE student_id = p_student_id;

  SELECT SUM(CASE WHEN e.grade >= 90 THEN 4
                  WHEN e.grade >= 80 THEN 3
                  WHEN e.grade >= 70 THEN 2
                  WHEN e.grade >= 60 THEN 1
                  ELSE 0 END * c.credits),
         SUM(c.credits)
    INTO v_points, v_credits
    FROM enrollments e
    JOIN courses c ON c.course_id = e.course_id
   WHERE e.student_id = p_student_id
     AND e.grade IS NOT NULL
     AND e.status <> 'DROPPED';

  IF v_credits IS NULL OR v_credits = 0 THEN
    RETURN NULL;
  END IF;
  RETURN ROUND(v_points / v_credits, 2);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    log_error('get_student_gpa', -20061, 'Student ' || p_student_id || ' not found');
    RAISE_APPLICATION_ERROR(-20061, 'Student ' || p_student_id || ' does not exist');
  WHEN OTHERS THEN
    log_error('get_student_gpa', SQLCODE, SQLERRM);
    RAISE;
END get_student_gpa;
/
SHOW ERRORS
