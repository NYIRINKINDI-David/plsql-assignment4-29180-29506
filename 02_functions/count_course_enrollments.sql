-- count_course_enrollments : number of seats used in a course (all non-DROPPED enrollments).
-- Can be called from SQL:  SELECT course_code, count_course_enrollments(course_id) FROM courses;
CREATE OR REPLACE FUNCTION count_course_enrollments (
  p_course_id IN courses.course_id%TYPE
) RETURN NUMBER IS
  v_id    courses.course_id%TYPE;
  v_count NUMBER;
BEGIN
  SELECT course_id INTO v_id FROM courses WHERE course_id = p_course_id;

  SELECT COUNT(*) INTO v_count
    FROM enrollments
   WHERE course_id = p_course_id
     AND status <> 'DROPPED';
  RETURN v_count;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    log_error('count_course_enrollments', -20062, 'Course ' || p_course_id || ' not found');
    RAISE_APPLICATION_ERROR(-20062, 'Course ' || p_course_id || ' does not exist');
  WHEN OTHERS THEN
    log_error('count_course_enrollments', SQLCODE, SQLERRM);
    RAISE;
END count_course_enrollments;
/
SHOW ERRORS
