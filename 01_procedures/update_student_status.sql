-- update_student_status : sets a student ACTIVE/INACTIVE. Deactivating also drops their ENROLLED courses.
-- Concepts: implicit cursor with UPDATE: SQL%NOTFOUND, SQL%FOUND, SQL%ROWCOUNT; user-defined exceptions.
-- Error codes: -20030 invalid status, -20031 student missing
CREATE OR REPLACE PROCEDURE update_student_status (
  p_student_id        IN  students.student_id%TYPE,
  p_new_status        IN  students.status%TYPE,
  p_enrollments_dropped OUT NUMBER
) IS
  e_invalid_status EXCEPTION;
  e_not_found      EXCEPTION;
BEGIN
  p_enrollments_dropped := 0;

  IF p_new_status IS NULL OR p_new_status NOT IN ('ACTIVE', 'INACTIVE') THEN
    RAISE e_invalid_status;
  END IF;

  UPDATE students SET status = p_new_status WHERE student_id = p_student_id;
  IF SQL%NOTFOUND THEN
    RAISE e_not_found;
  END IF;
  DBMS_OUTPUT.PUT_LINE('Student ' || p_student_id || ' set to ' || p_new_status ||
                       ' (rows updated: ' || SQL%ROWCOUNT || ')');

  IF p_new_status = 'INACTIVE' THEN
    UPDATE enrollments SET status = 'DROPPED'
     WHERE student_id = p_student_id AND status = 'ENROLLED';
    p_enrollments_dropped := SQL%ROWCOUNT;
    IF SQL%FOUND THEN
      DBMS_OUTPUT.PUT_LINE('  ' || p_enrollments_dropped || ' active enrollment(s) dropped');
    ELSE
      DBMS_OUTPUT.PUT_LINE('  student had no active enrollments to drop');
    END IF;
  END IF;
EXCEPTION
  WHEN e_invalid_status THEN
    RAISE_APPLICATION_ERROR(-20030, 'Status must be ACTIVE or INACTIVE (got ' || NVL(p_new_status, 'NULL') || ')');
  WHEN e_not_found THEN
    log_error('update_student_status', -20031, 'Student ' || p_student_id || ' not found');
    RAISE_APPLICATION_ERROR(-20031, 'Student ' || p_student_id || ' does not exist');
  WHEN OTHERS THEN
    log_error('update_student_status', SQLCODE, SQLERRM);
    RAISE;
END update_student_status;
/
SHOW ERRORS
