-- print_course_report : prints the class roster of a course with average grade.
-- Concepts: parameterized EXPLICIT cursor with OPEN / FETCH / CLOSE, cursor%ROWTYPE record,
--           cursor attributes (%NOTFOUND, %ROWCOUNT, %ISOPEN), NO_DATA_FOUND.
-- Error code: -20040 course missing
CREATE OR REPLACE PROCEDURE print_course_report (
  p_course_id IN courses.course_id%TYPE
) IS
  CURSOR c_roster (cp_course_id courses.course_id%TYPE) IS
    SELECT s.student_id,
           s.first_name || ' ' || s.last_name AS full_name,
           e.status,
           e.grade
      FROM enrollments e
      JOIN students s ON s.student_id = e.student_id
     WHERE e.course_id = cp_course_id
     ORDER BY s.last_name, s.first_name;

  v_row    c_roster%ROWTYPE;
  v_course courses%ROWTYPE;
  v_sum    NUMBER := 0;
  v_graded PLS_INTEGER := 0;
  v_total  PLS_INTEGER := 0;
BEGIN
  SELECT * INTO v_course FROM courses WHERE course_id = p_course_id;

  DBMS_OUTPUT.PUT_LINE('=== ' || v_course.course_code || ' - ' || v_course.title ||
                       ' (capacity ' || v_course.max_capacity || ') ===');
  DBMS_OUTPUT.PUT_LINE(RPAD('ID', 6) || RPAD('Student', 24) || RPAD('Status', 11) ||
                       RPAD('Grade', 8) || 'Letter');

  OPEN c_roster(p_course_id);
  LOOP
    FETCH c_roster INTO v_row;
    EXIT WHEN c_roster%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(RPAD(v_row.student_id, 6) || RPAD(v_row.full_name, 24) ||
                         RPAD(v_row.status, 11) || RPAD(NVL(TO_CHAR(v_row.grade), '-'), 8) ||
                         NVL(get_letter_grade(v_row.grade), '-'));
    IF v_row.grade IS NOT NULL THEN
      v_sum    := v_sum + v_row.grade;
      v_graded := v_graded + 1;
    END IF;
  END LOOP;
  v_total := c_roster%ROWCOUNT;
  CLOSE c_roster;

  IF v_total = 0 THEN
    DBMS_OUTPUT.PUT_LINE('(no enrollments in this course)');
  ELSIF v_graded = 0 THEN
    DBMS_OUTPUT.PUT_LINE('Total rows: ' || v_total || ' | no grades recorded yet');
  ELSE
    DBMS_OUTPUT.PUT_LINE('Total rows: ' || v_total || ' | graded: ' || v_graded ||
                         ' | average: ' || ROUND(v_sum / v_graded, 2));
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    log_error('print_course_report', -20040, 'Course ' || p_course_id || ' not found');
    RAISE_APPLICATION_ERROR(-20040, 'Course ' || p_course_id || ' does not exist');
  WHEN OTHERS THEN
    IF c_roster%ISOPEN THEN
      CLOSE c_roster;
    END IF;
    log_error('print_course_report', SQLCODE, SQLERRM);
    RAISE;
END print_course_report;
/
SHOW ERRORS
