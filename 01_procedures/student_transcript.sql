-- student_transcript : prints a student's transcript and returns the GPA.
-- Concepts: user-defined RECORD type, associative arrays (INDEX BY PLS_INTEGER and INDEX BY VARCHAR2),
--           cursor FOR loop, %ROWTYPE record, collection methods (COUNT, EXISTS, FIRST, NEXT).
-- Error code: -20050 student missing
CREATE OR REPLACE PROCEDURE student_transcript (
  p_student_id IN  students.student_id%TYPE,
  p_gpa        OUT NUMBER
) IS
  -- user-defined record
  TYPE t_course_rec IS RECORD (
    course_code courses.course_code%TYPE,
    title       courses.title%TYPE,
    credits     courses.credits%TYPE,
    status      enrollments.status%TYPE,
    grade       enrollments.grade%TYPE,
    letter      VARCHAR2(2)
  );
  -- associative array of records (integer index)
  TYPE t_course_tab IS TABLE OF t_course_rec INDEX BY PLS_INTEGER;
  -- associative array indexed by string: letter grade -> how many
  TYPE t_count_tab  IS TABLE OF PLS_INTEGER INDEX BY VARCHAR2(2);

  v_student students%ROWTYPE;
  v_courses t_course_tab;
  v_counts  t_count_tab;
  v_idx     PLS_INTEGER := 0;
  v_key     VARCHAR2(2);
  v_credits NUMBER := 0;
BEGIN
  SELECT * INTO v_student FROM students WHERE student_id = p_student_id;

  -- cursor FOR loop: fills the collection of records
  FOR r IN (SELECT c.course_code, c.title, c.credits, e.status, e.grade
              FROM enrollments e
              JOIN courses c ON c.course_id = e.course_id
             WHERE e.student_id = p_student_id
             ORDER BY c.course_code) LOOP
    v_idx := v_idx + 1;
    v_courses(v_idx).course_code := r.course_code;
    v_courses(v_idx).title       := r.title;
    v_courses(v_idx).credits     := r.credits;
    v_courses(v_idx).status      := r.status;
    v_courses(v_idx).grade       := r.grade;
    v_courses(v_idx).letter      := get_letter_grade(r.grade);
  END LOOP;

  DBMS_OUTPUT.PUT_LINE('=== TRANSCRIPT: ' || v_student.first_name || ' ' || v_student.last_name ||
                       ' (ID ' || v_student.student_id || ', ' || v_student.status || ') ===');

  IF v_courses.COUNT = 0 THEN
    DBMS_OUTPUT.PUT_LINE('(no enrollments)');
  ELSE
    DBMS_OUTPUT.PUT_LINE(RPAD('Course', 10) || RPAD('Title', 36) || RPAD('Cr', 4) ||
                         RPAD('Status', 11) || RPAD('Grade', 8) || 'Letter');
    FOR i IN 1 .. v_courses.COUNT LOOP
      DBMS_OUTPUT.PUT_LINE(RPAD(v_courses(i).course_code, 10) || RPAD(v_courses(i).title, 36) ||
                           RPAD(v_courses(i).credits, 4) || RPAD(v_courses(i).status, 11) ||
                           RPAD(NVL(TO_CHAR(v_courses(i).grade), '-'), 8) ||
                           NVL(v_courses(i).letter, '-'));
      IF v_courses(i).status <> 'DROPPED' THEN
        v_credits := v_credits + v_courses(i).credits;
      END IF;
      IF v_courses(i).letter IS NOT NULL THEN
        IF v_counts.EXISTS(v_courses(i).letter) THEN
          v_counts(v_courses(i).letter) := v_counts(v_courses(i).letter) + 1;
        ELSE
          v_counts(v_courses(i).letter) := 1;
        END IF;
      END IF;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Credits (non-dropped): ' || v_credits);
    v_key := v_counts.FIRST;
    WHILE v_key IS NOT NULL LOOP
      DBMS_OUTPUT.PUT_LINE('  Grade ' || v_key || ': ' || v_counts(v_key) || ' course(s)');
      v_key := v_counts.NEXT(v_key);
    END LOOP;
  END IF;

  p_gpa := get_student_gpa(p_student_id);
  DBMS_OUTPUT.PUT_LINE('GPA: ' || NVL(TO_CHAR(p_gpa, 'FM0.00'), 'n/a (no graded courses)'));
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    log_error('student_transcript', -20050, 'Student ' || p_student_id || ' not found');
    RAISE_APPLICATION_ERROR(-20050, 'Student ' || p_student_id || ' does not exist');
  WHEN OTHERS THEN
    log_error('student_transcript', SQLCODE, SQLERRM);
    RAISE;
END student_transcript;
/
SHOW ERRORS
