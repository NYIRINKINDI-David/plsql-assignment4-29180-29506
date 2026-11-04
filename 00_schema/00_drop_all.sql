-- 00_drop_all.sql : removes every object so the project can be rebuilt from scratch.
-- On the very first run you will see "does not exist" errors. That is expected.
DROP PROCEDURE log_error;
DROP PROCEDURE enroll_student;
DROP PROCEDURE bulk_enroll_students;
DROP PROCEDURE bulk_update_grades;
DROP PROCEDURE print_course_report;
DROP PROCEDURE student_transcript;
DROP PROCEDURE update_student_status;
DROP PROCEDURE delete_inactive_enrollments;
DROP PROCEDURE performance_compare;
DROP FUNCTION get_letter_grade;
DROP FUNCTION get_student_gpa;
DROP FUNCTION count_course_enrollments;
DROP FUNCTION find_student_by_lastname;
DROP FUNCTION get_top_students;
DROP TYPE t_top_students FORCE;
DROP TYPE t_student_gpa_obj FORCE;
DROP TYPE t_id_list FORCE;
DROP TABLE grade_audit  CASCADE CONSTRAINTS PURGE;
DROP TABLE enrollments  CASCADE CONSTRAINTS PURGE;
DROP TABLE courses      CASCADE CONSTRAINTS PURGE;
DROP TABLE students     CASCADE CONSTRAINTS PURGE;
DROP TABLE error_log    CASCADE CONSTRAINTS PURGE;
DROP TABLE perf_test    CASCADE CONSTRAINTS PURGE;
DROP SEQUENCE enrollment_seq;
