# Screenshot checklist (23 total)
Make the CMD window big first (`HOST mode con: cols=180 lines=55`). Each screenshot must show the command and its output.
The test files pause at every screenshot point: take the screenshot, then press ENTER.

| # | File name | What to capture |
|---|---|---|
| 1 | `setup_container_output.png` | `SHOW CON_NAME` = XEPDB1 |
| 2 | `create_user_output.png` | DROP/CREATE USER + GRANT |
| 3 | `setup_connection_output.png` | CONNECT + `SHOW USER` + empty table list |
| 4 | `create_tables_output.png` | create tables + table list |
| 5 | `insert_sample_data_output.png` | row counts (10 / 5 / 29) |
| 6 | `compile_functions_output.png` | log_error + 5 functions created |
| 7 | `compile_procedures_output.png` | 8 procedures created |
| 8 | `compile_objects_output.png` | all objects VALID |
| 9 | `test_functions_output.png` | success tests 1-2 |
| 10 | `test_top_students_output.png` | success test 3 |
| 11 | `test_student_transcript_output.png` | success test 4 |
| 12 | `test_print_course_report_output.png` | success test 5 |
| 13 | `test_enroll_student_output.png` | success tests 6-7 |
| 14 | `test_bulk_update_grades_output.png` | success test 8 |
| 15 | `test_update_and_delete_output.png` | success tests 9-10 |
| 16 | `test_performance_compare_output.png` | success test 11 + rollback |
| 17 | `test_predefined_exceptions_output.png` | error E1 |
| 18 | `test_enroll_student_errors_output.png` | errors E2-E6 |
| 19 | `test_function_errors_output.png` | errors E7-E11 |
| 20 | `test_forall_save_exceptions_output.png` | error E12 |
| 21 | `test_bulk_and_dml_errors_output.png` | errors E13-E16 |
| 22 | `test_report_and_constraint_errors_output.png` | errors E17-E19 + rollback |
| 23 | `test_error_log_output.png` | ERROR_LOG listing |
