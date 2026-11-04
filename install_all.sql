-- install_all.sql : rebuilds the whole project. Run from the repository root:
--   sqlplus grading_app/YourPassword123@localhost:1521/XEPDB1
--   SQL> @install_all.sql
SET SERVEROUTPUT ON SIZE UNLIMITED
SET LINESIZE 200
SET PAGESIZE 100
SET DEFINE OFF
PROMPT ===== 1. Drop old objects (errors on first run are expected) =====
@00_schema/00_drop_all.sql
PROMPT ===== 2. Schema =====
@00_schema/01_create_tables.sql
PROMPT ===== 3. Sample data =====
@00_schema/02_insert_sample_data.sql
PROMPT ===== 4. Logging procedure (used by everything else) =====
@01_procedures/log_error.sql
PROMPT ===== 5. Functions =====
@02_functions/get_letter_grade.sql
@02_functions/get_student_gpa.sql
@02_functions/count_course_enrollments.sql
@02_functions/find_student_by_lastname.sql
@02_functions/get_top_students.sql
PROMPT ===== 6. Remaining procedures =====
@01_procedures/enroll_student.sql
@01_procedures/bulk_enroll_students.sql
@01_procedures/bulk_update_grades.sql
@01_procedures/print_course_report.sql
@01_procedures/student_transcript.sql
@01_procedures/update_student_status.sql
@01_procedures/delete_inactive_enrollments.sql
@01_procedures/performance_compare.sql
PROMPT ===== 7. Compile check (should list no rows) =====
SELECT object_name, object_type, status FROM user_objects
 WHERE status <> 'VALID' AND object_type IN ('PROCEDURE','FUNCTION','TYPE');
SELECT object_type, COUNT(*) AS objects FROM user_objects
 WHERE object_type IN ('PROCEDURE','FUNCTION','TYPE') GROUP BY object_type;
