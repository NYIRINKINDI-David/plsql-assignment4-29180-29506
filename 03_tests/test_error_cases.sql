-- test_error_cases.sql : every block triggers an error ON PURPOSE and prints how it was handled.
-- Run AFTER install_all.sql. Changes are rolled back at the end; ERROR_LOG entries are kept
-- (log_error uses an autonomous transaction) and displayed at the very end.
SET SERVEROUTPUT ON SIZE UNLIMITED
SET LINESIZE 200
SET PAGESIZE 100
SET FEEDBACK ON
CLEAR SCREEN

PROMPT
PROMPT ===== E1: Predefined exceptions caught directly =====
DECLARE
  v_id NUMBER;
  v_n  NUMBER := 0;
BEGIN
  BEGIN
    SELECT student_id INTO v_id FROM students WHERE student_id = 99999;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('NO_DATA_FOUND caught: no student with ID 99999');
  END;
  BEGIN
    SELECT student_id INTO v_id FROM students WHERE last_name = 'Mukamana';
  EXCEPTION WHEN TOO_MANY_ROWS THEN
    DBMS_OUTPUT.PUT_LINE('TOO_MANY_ROWS caught: several students are named Mukamana');
  END;
  BEGIN
    v_id := 10 / v_n;
  EXCEPTION WHEN ZERO_DIVIDE THEN
    DBMS_OUTPUT.PUT_LINE('ZERO_DIVIDE caught: division by zero');
  END;
  BEGIN
    INSERT INTO students (student_id, first_name, last_name, email) VALUES (101, 'Dup', 'Licate', 'dup@auca.ac.rw');
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
    DBMS_OUTPUT.PUT_LINE('DUP_VAL_ON_INDEX caught: student_id 101 already exists');
  END;
END;
/

PAUSE >>> SCREENSHOT 17/23 NOW - then press ENTER to continue
CLEAR SCREEN
PROMPT
PROMPT ===== E2: enroll_student - unknown student (-20001) =====
DECLARE v_id NUMBER;
BEGIN
  enroll_student(999, 1, v_id);
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Handled -> SQLCODE=' || SQLCODE || ' | ' || SQLERRM);
END;
/

PROMPT
PROMPT ===== E3: enroll_student - unknown course (-20005) =====
DECLARE v_id NUMBER;
BEGIN
  enroll_student(101, 99, v_id);
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Handled -> SQLCODE=' || SQLCODE || ' | ' || SQLERRM);
END;
/

PROMPT
PROMPT ===== E4: enroll_student - inactive student, user-defined exception (-20002) =====
DECLARE v_id NUMBER;
BEGIN
  enroll_student(110, 3, v_id);
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Handled -> SQLCODE=' || SQLCODE || ' | ' || SQLERRM);
END;
/

PROMPT
PROMPT ===== E5: enroll_student - course full, user-defined exception (-20003) =====
DECLARE v_id NUMBER;
BEGIN
  enroll_student(105, 5, v_id);
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Handled -> SQLCODE=' || SQLCODE || ' | ' || SQLERRM);
END;
/

PROMPT
PROMPT ===== E6: enroll_student - duplicate enrollment, DUP_VAL_ON_INDEX (-20004) =====
DECLARE v_id NUMBER;
BEGIN
  enroll_student(101, 1, v_id);
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Handled -> SQLCODE=' || SQLCODE || ' | ' || SQLERRM);
END;
/

PAUSE >>> SCREENSHOT 18/23 NOW - then press ENTER to continue
CLEAR SCREEN
PROMPT
PROMPT ===== E7: get_letter_grade - score out of range (-20060) =====
BEGIN
  DBMS_OUTPUT.PUT_LINE('Letter = ' || get_letter_grade(150));
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Handled -> SQLCODE=' || SQLCODE || ' | ' || SQLERRM);
END;
/

PROMPT
PROMPT ===== E8: get_student_gpa - unknown student (-20061) =====
BEGIN
  DBMS_OUTPUT.PUT_LINE('GPA = ' || get_student_gpa(999));
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Handled -> SQLCODE=' || SQLCODE || ' | ' || SQLERRM);
END;
/

PROMPT
PROMPT ===== E9: find_student_by_lastname - NO_DATA_FOUND (-20063) and TOO_MANY_ROWS (-20064) =====
BEGIN
  DBMS_OUTPUT.PUT_LINE('ID = ' || find_student_by_lastname('Nobody'));
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Handled -> SQLCODE=' || SQLCODE || ' | ' || SQLERRM);
END;
/
BEGIN
  DBMS_OUTPUT.PUT_LINE('ID = ' || find_student_by_lastname('Mukamana'));
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Handled -> SQLCODE=' || SQLCODE || ' | ' || SQLERRM);
END;
/

PROMPT
PROMPT ===== E10: count_course_enrollments - unknown course (-20062) =====
BEGIN
  DBMS_OUTPUT.PUT_LINE('Seats = ' || count_course_enrollments(99));
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Handled -> SQLCODE=' || SQLCODE || ' | ' || SQLERRM);
END;
/

PROMPT
PROMPT ===== E11: get_top_students - invalid limit (-20065) =====
DECLARE v_top t_top_students;
BEGIN
  v_top := get_top_students(0);
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Handled -> SQLCODE=' || SQLCODE || ' | ' || SQLERRM);
END;
/

PAUSE >>> SCREENSHOT 19/23 NOW - then press ENTER to continue
CLEAR SCREEN
PROMPT
PROMPT ===== E12: bulk_enroll_students - FORALL SAVE EXCEPTIONS (unknown ID 999, duplicate 101) =====
DECLARE
  v_ok NUMBER; v_bad NUMBER;
BEGIN
  bulk_enroll_students(2, t_id_list(103, 108, 106, 999, 101), v_ok, v_bad);
  DBMS_OUTPUT.PUT_LINE('OUT: success=' || v_ok || ' failed=' || v_bad || '  (expected 3 and 2)');
END;
/
SELECT student_id, course_id FROM enrollments WHERE course_id = 2 AND student_id IN (103, 106, 108) ORDER BY student_id;

PAUSE >>> SCREENSHOT 20/23 NOW - then press ENTER to continue
CLEAR SCREEN
PROMPT
PROMPT ===== E13: bulk_enroll_students - empty list (-20020), unknown course (-20021), not enough seats (-20022) =====
DECLARE
  v_ok NUMBER; v_bad NUMBER;
BEGIN
  bulk_enroll_students(1, t_id_list(), v_ok, v_bad);
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Handled -> SQLCODE=' || SQLCODE || ' | ' || SQLERRM);
END;
/
DECLARE
  v_ok NUMBER; v_bad NUMBER;
BEGIN
  bulk_enroll_students(99, t_id_list(101), v_ok, v_bad);
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Handled -> SQLCODE=' || SQLCODE || ' | ' || SQLERRM);
END;
/
DECLARE
  v_ok NUMBER; v_bad NUMBER;
BEGIN
  bulk_enroll_students(5, t_id_list(103), v_ok, v_bad);   -- course 5 is already full
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Handled -> SQLCODE=' || SQLCODE || ' | ' || SQLERRM);
END;
/

PROMPT
PROMPT ===== E14: bulk_update_grades - invalid curve (-20010), no graded rows (-20011), unknown course (-20012) =====
DECLARE v_rows NUMBER;
BEGIN
  bulk_update_grades(1, 50, v_rows);
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Handled -> SQLCODE=' || SQLCODE || ' | ' || SQLERRM);
END;
/
DECLARE v_rows NUMBER;
BEGIN
  bulk_update_grades(5, 5, v_rows);   -- seminar has no grades
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Handled -> SQLCODE=' || SQLCODE || ' | ' || SQLERRM);
END;
/
DECLARE v_rows NUMBER;
BEGIN
  bulk_update_grades(99, 5, v_rows);
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Handled -> SQLCODE=' || SQLCODE || ' | ' || SQLERRM);
END;
/

PROMPT
PROMPT ===== E15: update_student_status - invalid status (-20030) and SQL%NOTFOUND (-20031) =====
DECLARE v_dropped NUMBER;
BEGIN
  update_student_status(101, 'SUSPENDED', v_dropped);
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Handled -> SQLCODE=' || SQLCODE || ' | ' || SQLERRM);
END;
/
DECLARE v_dropped NUMBER;
BEGIN
  update_student_status(999, 'INACTIVE', v_dropped);
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Handled -> SQLCODE=' || SQLCODE || ' | ' || SQLERRM);
END;
/

PROMPT
PROMPT ===== E16: delete_inactive_enrollments - unknown course (-20035) =====
DECLARE v_del NUMBER;
BEGIN
  delete_inactive_enrollments(p_course_id => 99, p_deleted => v_del);
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Handled -> SQLCODE=' || SQLCODE || ' | ' || SQLERRM);
END;
/

PAUSE >>> SCREENSHOT 21/23 NOW - then press ENTER to continue
CLEAR SCREEN
PROMPT
PROMPT ===== E17: print_course_report (-20040) and student_transcript (-20050) with unknown IDs =====
BEGIN
  print_course_report(99);
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Handled -> SQLCODE=' || SQLCODE || ' | ' || SQLERRM);
END;
/
DECLARE v_gpa NUMBER;
BEGIN
  student_transcript(999, v_gpa);
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Handled -> SQLCODE=' || SQLCODE || ' | ' || SQLERRM);
END;
/

PROMPT
PROMPT ===== E18: performance_compare - invalid row count (-20070) =====
BEGIN
  performance_compare(5);
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Handled -> SQLCODE=' || SQLCODE || ' | ' || SQLERRM);
END;
/

PROMPT
PROMPT ===== E19: Constraint violations raised by the database itself (CHECK, FK) =====
BEGIN
  UPDATE enrollments SET grade = 150 WHERE enrollment_id = 1;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('CHECK constraint -> SQLCODE=' || SQLCODE || ' | ' || SQLERRM);
END;
/
BEGIN
  INSERT INTO enrollments (enrollment_id, student_id, course_id) VALUES (enrollment_seq.NEXTVAL, 999, 1);
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('FOREIGN KEY -> SQLCODE=' || SQLCODE || ' | ' || SQLERRM);
END;
/

PROMPT
PROMPT ===== Cleaning up: rolling back test changes =====
ROLLBACK;

PAUSE >>> SCREENSHOT 22/23 NOW - then press ENTER to continue
CLEAR SCREEN
PROMPT
PROMPT ===== ERROR_LOG contents (kept by the autonomous transaction) =====
COLUMN source_name   FORMAT A28
COLUMN error_message FORMAT A100
SELECT log_id, source_name, error_code, SUBSTR(error_message, 1, 100) AS error_message FROM error_log ORDER BY log_id;
PAUSE >>> SCREENSHOT 23/23 NOW - then press ENTER to continue
