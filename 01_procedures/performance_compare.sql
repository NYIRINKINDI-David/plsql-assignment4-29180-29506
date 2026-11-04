-- performance_compare : times row-by-row DML against FORALL bulk DML on the scratch table PERF_TEST.
-- Runs as an AUTONOMOUS transaction and ROLLS BACK its own work, so it never touches the caller's data.
-- DBMS_UTILITY.GET_TIME measures in hundredths of a second.
-- Error code: -20070 invalid row count
CREATE OR REPLACE PROCEDURE performance_compare (
  p_rows IN PLS_INTEGER DEFAULT 10000
) IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  TYPE t_id_tab  IS TABLE OF perf_test.id%TYPE  INDEX BY PLS_INTEGER;
  TYPE t_val_tab IS TABLE OF perf_test.val%TYPE INDEX BY PLS_INTEGER;
  v_ids  t_id_tab;
  v_vals t_val_tab;
  v_t0   NUMBER;
  v_row_ins  NUMBER;
  v_blk_ins  NUMBER;
  v_row_upd  NUMBER;
  v_blk_upd  NUMBER;
  e_invalid_rows EXCEPTION;

  PROCEDURE print_row (p_label VARCHAR2, p_row NUMBER, p_bulk NUMBER) IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE(RPAD(p_label, 8) || ' row-by-row: ' || LPAD(p_row, 6) || ' cs | FORALL: ' ||
                         LPAD(p_bulk, 6) || ' cs | speed-up: ' ||
                         CASE WHEN p_bulk > 0 THEN TO_CHAR(ROUND(p_row / p_bulk, 1)) || 'x'
                              ELSE 'n/a (bulk < 1 cs)' END);
  END print_row;
BEGIN
  IF p_rows IS NULL OR p_rows < 100 OR p_rows > 1000000 THEN
    RAISE e_invalid_rows;
  END IF;

  DELETE FROM perf_test;

  -- 1) Row-by-row INSERT: one SQL call (context switch) per row
  v_t0 := DBMS_UTILITY.GET_TIME;
  FOR i IN 1 .. p_rows LOOP
    INSERT INTO perf_test (id, val, amount) VALUES (i, 'ROW_' || i, i);
  END LOOP;
  v_row_ins := DBMS_UTILITY.GET_TIME - v_t0;

  -- 2) Row-by-row UPDATE
  v_t0 := DBMS_UTILITY.GET_TIME;
  FOR i IN 1 .. p_rows LOOP
    UPDATE perf_test SET amount = amount * 1.1 WHERE id = i;
  END LOOP;
  v_row_upd := DBMS_UTILITY.GET_TIME - v_t0;

  DELETE FROM perf_test;

  -- 3) FORALL INSERT: whole collection sent to SQL engine in ONE call
  FOR i IN 1 .. p_rows LOOP
    v_ids(i)  := i;
    v_vals(i) := 'ROW_' || i;
  END LOOP;
  v_t0 := DBMS_UTILITY.GET_TIME;
  FORALL i IN 1 .. p_rows
    INSERT INTO perf_test (id, val, amount) VALUES (v_ids(i), v_vals(i), v_ids(i));
  v_blk_ins := DBMS_UTILITY.GET_TIME - v_t0;

  -- 4) FORALL UPDATE
  v_t0 := DBMS_UTILITY.GET_TIME;
  FORALL i IN 1 .. p_rows
    UPDATE perf_test SET amount = amount * 1.1 WHERE id = v_ids(i);
  v_blk_upd := DBMS_UTILITY.GET_TIME - v_t0;

  ROLLBACK;   -- leave PERF_TEST empty; ends the autonomous transaction

  DBMS_OUTPUT.PUT_LINE('=== Performance comparison for ' || p_rows || ' rows (cs = 1/100 s) ===');
  print_row('INSERT', v_row_ins, v_blk_ins);
  print_row('UPDATE', v_row_upd, v_blk_upd);
EXCEPTION
  WHEN e_invalid_rows THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20070, 'p_rows must be between 100 and 1,000,000');
  WHEN OTHERS THEN
    ROLLBACK;
    log_error('performance_compare', SQLCODE, SQLERRM);
    RAISE;
END performance_compare;
/
SHOW ERRORS
