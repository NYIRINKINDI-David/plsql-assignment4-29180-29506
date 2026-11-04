-- find_student_by_lastname : returns the student_id for a last name.
-- Demonstrates the predefined exceptions NO_DATA_FOUND and TOO_MANY_ROWS.
CREATE OR REPLACE FUNCTION find_student_by_lastname (
  p_last_name IN students.last_name%TYPE
) RETURN NUMBER IS
  v_id students.student_id%TYPE;
BEGIN
  SELECT student_id INTO v_id
    FROM students
   WHERE UPPER(last_name) = UPPER(p_last_name);
  RETURN v_id;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    log_error('find_student_by_lastname', -20063, 'No student with last name ' || p_last_name);
    RAISE_APPLICATION_ERROR(-20063, 'No student found with last name ' || p_last_name);
  WHEN TOO_MANY_ROWS THEN
    log_error('find_student_by_lastname', -20064, 'Several students with last name ' || p_last_name);
    RAISE_APPLICATION_ERROR(-20064, 'More than one student has last name ' || p_last_name || '; search by ID instead');
  WHEN OTHERS THEN
    log_error('find_student_by_lastname', SQLCODE, SQLERRM);
    RAISE;
END find_student_by_lastname;
/
SHOW ERRORS
