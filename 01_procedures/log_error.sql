-- log_error : writes an error to ERROR_LOG in an AUTONOMOUS transaction, so the log
-- survives even when the caller rolls back. It never hides the original error:
-- if logging itself fails, a message is printed and the caller's error still propagates.
CREATE OR REPLACE PROCEDURE log_error (
  p_source  IN VARCHAR2,
  p_code    IN NUMBER,
  p_message IN VARCHAR2
) IS
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  INSERT INTO error_log (source_name, error_code, error_message)
  VALUES (p_source, p_code, SUBSTR(p_message, 1, 4000));
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('WARNING: could not write to ERROR_LOG: ' || SQLERRM);
END log_error;
/
SHOW ERRORS
