-- delete_inactive_enrollments : permanently removes DROPPED enrollments (optionally for one course).
-- Concepts: implicit cursor with DELETE: SQL%FOUND, SQL%NOTFOUND, SQL%ROWCOUNT.
-- Deleting nothing is not an error; the procedure reports it and returns 0.
-- Error code: -20035 course missing
CREATE OR REPLACE PROCEDURE delete_inactive_enrollments (
  p_course_id IN  courses.course_id%TYPE DEFAULT NULL,
  p_deleted   OUT NUMBER
) IS
  v_dummy courses.course_id%TYPE;
BEGIN
  p_deleted := 0;

  IF p_course_id IS NOT NULL THEN
    SELECT course_id INTO v_dummy FROM courses WHERE course_id = p_course_id;
  END IF;

  DELETE FROM enrollments
   WHERE status = 'DROPPED'
     AND (p_course_id IS NULL OR course_id = p_course_id);

  p_deleted := SQL%ROWCOUNT;
  IF SQL%FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Deleted ' || p_deleted || ' dropped enrollment(s)');
  ELSIF SQL%NOTFOUND THEN
    DBMS_OUTPUT.PUT_LINE('Nothing to delete: no dropped enrollments matched');
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    log_error('delete_inactive_enrollments', -20035, 'Course ' || p_course_id || ' not found');
    RAISE_APPLICATION_ERROR(-20035, 'Course ' || p_course_id || ' does not exist');
  WHEN OTHERS THEN
    log_error('delete_inactive_enrollments', SQLCODE, SQLERRM);
    RAISE;
END delete_inactive_enrollments;
/
SHOW ERRORS
