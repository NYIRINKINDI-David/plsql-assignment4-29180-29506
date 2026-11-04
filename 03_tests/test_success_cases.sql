-- test_success_cases.sql : happy-path tests. Everything is ROLLED BACK at the end,
-- so the file can be re-run any number of times. Run AFTER install_all.sql.
SET SERVEROUTPUT ON SIZE UNLIMITED
SET LINESIZE 200
SET PAGESIZE 100
SET FEEDBACK ON
CLEAR SCREEN

PROMPT
PROMPT ===== TEST 1: get_letter_grade (SQL + anonymous block) =====
SELECT get_letter_grade(95) AS g95, get_letter_grade(85) AS g85, get_letter_grade(72) AS g72,
       get_letter_grade(61) AS g61, get_letter_grade(40) AS g40, get_letter_grade(NULL) AS gnull
  FROM dual;
BEGIN
  DBMS_OUTPUT.PUT_LINE('Letter for 88.5 = ' || get_letter_grade(88.5));
END;
/

PROMPT
PROMPT ===== TEST 2: get_student_gpa + count_course_enrollments + find_student_by_lastname (called from SQL) =====
SELECT student_id, first_name, last_name, get_student_gpa(student_id) AS gpa FROM students ORDER BY student_id;
SELECT course_code, max_capacity, count_course_enrollments(course_id) AS seats_used FROM courses ORDER BY course_id;
SELECT find_student_by_lastname('Habimana') AS habimana_id FROM dual;

PAUSE >>> SCREENSHOT 9/23 NOW - then press ENTER to continue
CLEAR SCREEN
PROMPT
PROMPT ===== TEST 3: get_top_students (VARRAY) =====
SELECT * FROM TABLE(get_top_students(3));
DECLARE
  v_top t_top_students;
BEGIN
  v_top := get_top_students(5);
  FOR i IN 1 .. v_top.COUNT LOOP
    DBMS_OUTPUT.PUT_LINE(i || '. ' || v_top(i).full_name || ' - GPA ' || v_top(i).gpa);
  END LOOP;
END;
/

PAUSE >>> SCREENSHOT 10/23 NOW - then press ENTER to continue
CLEAR SCREEN
PROMPT
PROMPT ===== TEST 4: student_transcript (user-defined record, associative arrays, cursor FOR loop) =====
DECLARE
  v_gpa NUMBER;
BEGIN
  student_transcript(101, v_gpa);
  DBMS_OUTPUT.PUT_LINE('Returned GPA = ' || v_gpa);
  student_transcript(105, v_gpa);   -- has a DROPPED course and ungraded rows
END;
/

PAUSE >>> SCREENSHOT 11/23 NOW - then press ENTER to continue
CLEAR SCREEN
PROMPT
PROMPT ===== TEST 5: print_course_report (explicit cursor OPEN/FETCH/CLOSE) =====
BEGIN
  print_course_report(1);
  print_course_report(5);   -- no grades yet
END;
/

PAUSE >>> SCREENSHOT 12/23 NOW - then press ENTER to continue
CLEAR SCREEN
PROMPT
PROMPT ===== TEST 6: enroll_student (implicit cursor INSERT) =====
DECLARE
  v_enr_id NUMBER;
BEGIN
  enroll_student(105, 4, v_enr_id);
  DBMS_OUTPUT.PUT_LINE('New enrollment_id = ' || v_enr_id);
END;
/
SELECT enrollment_id, student_id, course_id, status FROM enrollments WHERE student_id = 105 AND course_id = 4;

PROMPT
PROMPT ===== TEST 7: bulk_enroll_students (FORALL, all rows valid) =====
DECLARE
  v_ok NUMBER; v_bad NUMBER;
BEGIN
  bulk_enroll_students(4, t_id_list(101, 104, 107), v_ok, v_bad);
  DBMS_OUTPUT.PUT_LINE('OUT: success=' || v_ok || ' failed=' || v_bad);
END;
/
SELECT count_course_enrollments(4) AS seats_used_in_course_4 FROM dual;

PAUSE >>> SCREENSHOT 13/23 NOW - then press ENTER to continue
CLEAR SCREEN
PROMPT
PROMPT ===== TEST 8: bulk_update_grades (BULK COLLECT + FORALL, +5 curve on course 1) =====
DECLARE
  v_rows NUMBER;
BEGIN
  bulk_update_grades(1, 5, v_rows);
  DBMS_OUTPUT.PUT_LINE('OUT: rows updated = ' || v_rows);
END;
/
SELECT audit_id, enrollment_id, old_grade, new_grade FROM grade_audit ORDER BY audit_id;
BEGIN
  print_course_report(1);
END;
/

PAUSE >>> SCREENSHOT 14/23 NOW - then press ENTER to continue
CLEAR SCREEN
PROMPT
PROMPT ===== TEST 9: update_student_status (implicit cursor UPDATE) =====
DECLARE
  v_dropped NUMBER;
BEGIN
  update_student_status(107, 'INACTIVE', v_dropped);
  DBMS_OUTPUT.PUT_LINE('OUT: enrollments dropped = ' || v_dropped);
END;
/

PROMPT
PROMPT ===== TEST 10: delete_inactive_enrollments (implicit cursor DELETE) =====
DECLARE
  v_del NUMBER;
BEGIN
  delete_inactive_enrollments(p_course_id => NULL, p_deleted => v_del);
  DBMS_OUTPUT.PUT_LINE('OUT: deleted = ' || v_del);
  delete_inactive_enrollments(p_course_id => NULL, p_deleted => v_del);   -- second call: SQL%NOTFOUND branch
  DBMS_OUTPUT.PUT_LINE('OUT: deleted = ' || v_del);
END;
/

PAUSE >>> SCREENSHOT 15/23 NOW - then press ENTER to continue
CLEAR SCREEN
PROMPT
PROMPT ===== TEST 11: performance_compare (row-by-row vs FORALL) =====
BEGIN
  performance_compare(20000);
END;
/

PROMPT
PROMPT ===== Cleaning up: rolling back test changes =====
ROLLBACK;
SELECT COUNT(*) AS enrollments_after_rollback FROM enrollments;
PAUSE >>> SCREENSHOT 16/23 NOW - then press ENTER to continue
