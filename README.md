# Group Assignment IV – Advanced Oracle PL/SQL (INSY 8311)

**Application:** Student Registration and Grading System

## Group members
| Name | Student ID | Class group |
|------|-----------|-------------|
| NYIRINKINDI David | 29180 |  C
| NDAGIJIMANA Rasana Bonte | 29506 |  D

Course: Database Development with PL/SQL – Instructor: Eric Maniraguha

## 1. Application description and requirements
A university registrar needs to enroll students in courses, record and curve grades, produce class
rosters and transcripts, calculate GPAs and clean up dropped enrollments.

**Business rules**
- Only ACTIVE students may enroll; a student can enroll in a given course only once.
- A course cannot exceed its `max_capacity` (dropped enrollments free their seat).
- Grades are 0–100; letters: A ≥ 90, B ≥ 80, C ≥ 70, D ≥ 60, otherwise F.
- GPA is credit-weighted on a 4.0 scale and ignores dropped/ungraded courses (NULL when there is nothing to average).
- Deactivating a student drops their active enrollments.
- Every grade change made in bulk is written to `GRADE_AUDIT`; every handled error is written to `ERROR_LOG`.

## 2. Schema
`STUDENTS`, `COURSES`, `ENROLLMENTS` (link table, UNIQUE(student, course), CHECK grade 0–100), `GRADE_AUDIT`,
`ERROR_LOG`, `PERF_TEST` (scratch table for timing) + sequence `ENROLLMENT_SEQ` and collection types
`T_ID_LIST` (nested table), `T_STUDENT_GPA_OBJ` + `T_TOP_STUDENTS` (VARRAY). See `00_schema/01_create_tables.sql`.

```
STUDENTS 1 ──< ENROLLMENTS >── 1 COURSES
                   │ 1
                   └──< GRADE_AUDIT
```

## 3. Concept → file map
| Requirement | Where it is demonstrated |
|---|---|
| %ROWTYPE records | `enroll_student`, `print_course_report` (cursor%ROWTYPE), `student_transcript`, `bulk_enroll_students` |
| User-defined record | `student_transcript` (`t_course_rec`) |
| Associative arrays | `student_transcript` (INDEX BY PLS_INTEGER and INDEX BY VARCHAR2), `performance_compare` |
| Nested table | `t_id_list` in `bulk_enroll_students`; local types in `bulk_update_grades` |
| VARRAY | `get_top_students` returns `t_top_students` |
| Implicit cursor INSERT | `enroll_student` (SQL%FOUND, SQL%ROWCOUNT) |
| Implicit cursor UPDATE | `update_student_status` (SQL%NOTFOUND, SQL%FOUND, SQL%ROWCOUNT) |
| Implicit cursor DELETE | `delete_inactive_enrollments` (SQL%FOUND / SQL%NOTFOUND) |
| Explicit cursor OPEN/FETCH/CLOSE | `print_course_report` |
| Cursor FOR loop | `student_transcript`, `get_top_students` |
| BULK COLLECT | `bulk_update_grades` |
| FORALL (INSERT/UPDATE) | `bulk_enroll_students`, `bulk_update_grades`, `performance_compare` |
| Bulk DML errors (SAVE EXCEPTIONS) | `bulk_enroll_students`, `bulk_update_grades` |
| Predefined exceptions | NO_DATA_FOUND / TOO_MANY_ROWS in `find_student_by_lastname`; DUP_VAL_ON_INDEX in `enroll_student`; test E1 |
| User-defined exceptions | `e_student_inactive`, `e_course_full`, `e_invalid_curve`, `e_no_grades`, … |
| RAISE_APPLICATION_ERROR | all procedures/functions (codes -20001 … -20070) |
| Functions callable from SQL | `get_letter_grade`, `get_student_gpa`, `count_course_enrollments`, `find_student_by_lastname`, `TABLE(get_top_students(n))` |
| Autonomous-transaction logging | `log_error` |

## 4. How to run
Run everything from the **repository root** so relative paths work.

```
sqlplus / as sysdba
SQL> ALTER SESSION SET CONTAINER = XEPDB1;            -- skip if not using a PDB
SQL> CREATE USER grading_app IDENTIFIED BY YourPassword123;
SQL> GRANT CONNECT, RESOURCE, CREATE VIEW, UNLIMITED TABLESPACE TO grading_app;
SQL> CONNECT grading_app/YourPassword123@localhost:1521/XEPDB1
SQL> SET SERVEROUTPUT ON SIZE UNLIMITED
```

**Option A – one command:** `SQL> @install_all.sql` then `SQL> @run_tests.sql`

**Option B – step by step (same order as the assignment)**
1. `@00_schema/01_create_tables.sql`
2. `@00_schema/02_insert_sample_data.sql`
3. `@01_procedures/log_error.sql` (every other unit calls it)
4. `@02_functions/get_letter_grade.sql`, `get_student_gpa.sql`, `count_course_enrollments.sql`, `find_student_by_lastname.sql`, `get_top_students.sql`
   (compiled before the other procedures because `print_course_report` and `student_transcript` call `get_letter_grade` / `get_student_gpa`)
5. Remaining files in `01_procedures/`
6. `@03_tests/test_success_cases.sql` then `@03_tests/test_error_cases.sql`

To reset the project: `@00_schema/00_drop_all.sql` (first-run "does not exist" errors are expected).
Screenshots go in `screenshots/` (see `docs/SCREENSHOT_CHECKLIST.md`). Design/performance notes: `docs/IMPLEMENTATION_NOTES.md`.

## 5. AI usage statement
We used an AI assistant (Claude, by Anthropic).AI tools were used as supporting resources during the planning and initial development of this project. They assisted with generating ideas, drafting some SQL/PL/SQL scripts, and organizing the documentation. Both group members reviewed, tested, modified, and verified the implementation to ensure that we understood the code and that it met the assignment requirements.