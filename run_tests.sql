-- run_tests.sql : runs both test files and spools the output to screenshots/*.log
-- The test files PAUSE at each screenshot point: press ENTER to continue.
SET SERVEROUTPUT ON SIZE UNLIMITED
SET LINESIZE 200
SET PAGESIZE 100
SPOOL screenshots/test_success_cases.log
@03_tests/test_success_cases.sql
SPOOL OFF
SPOOL screenshots/test_error_cases.log
@03_tests/test_error_cases.sql
SPOOL OFF
