# Implementation and Performance Notes

## Design decisions
- **Scenario:** Student registration and grading; small schema (3 core tables + audit + error log) that still allows every required concept.
- **Single-row vs. set-based work:** `enroll_student` handles one enrollment with full validation; `bulk_enroll_students` and `bulk_update_grades` handle many rows with collections and FORALL.
- **Transaction control:** procedures do not COMMIT, so the caller decides (tests ROLLBACK to stay repeatable). `log_error` and `performance_compare` use `PRAGMA AUTONOMOUS_TRANSACTION` so logging survives a rollback and the benchmark never touches the caller's data.
- **Schema-level types** (`t_id_list`, `t_top_students`) are used because they can be passed as parameters and queried with `TABLE()`.
- **Seat counting:** a seat is used by every enrollment whose status is not `DROPPED`; the same rule is used by `enroll_student`, `bulk_enroll_students` and `count_course_enrollments`.

## Exception-handling strategy
1. **Expected business errors** (unknown student, full course, bad input) are detected with predefined or user-defined exceptions, logged with `log_error`, and re-raised as `RAISE_APPLICATION_ERROR` with a unique code in -20001 … -20070 and a readable message.
2. **Unexpected errors** are caught by `WHEN OTHERS`, logged, and re-raised with `RAISE`; nothing is swallowed.
3. **Functions never return misleading values:** `get_student_gpa` returns NULL (not 0) when no grades exist; invalid input raises an error instead of returning a default.
4. **Bulk DML:** `FORALL ... SAVE EXCEPTIONS` lets good rows succeed; ORA-24381 is mapped with `PRAGMA EXCEPTION_INIT`, each bad row is reported from `SQL%BULK_EXCEPTIONS` (index + error code) and logged. `bulk_update_grades` raises -20013 if any row fails so the caller can roll back.

| Code | Meaning | Code | Meaning |
|---|---|---|---|
| -20001 | student missing (enroll) | -20035 | course missing (delete) |
| -20002 | student inactive | -20040 | course missing (report) |
| -20003 | course full | -20050 | student missing (transcript) |
| -20004 | duplicate enrollment | -20060 | score out of range |
| -20005 | course missing (enroll) | -20061 | student missing (GPA) |
| -20010 | invalid curve | -20062 | course missing (count) |
| -20011 | no graded rows | -20063 | last name not found |
| -20012 | course missing (bulk grade) | -20064 | last name ambiguous |
| -20013 | bulk update row errors | -20065 | invalid top-N limit |
| -20020 | empty student list | -20070 | invalid row count (perf) |
| -20021 | course missing (bulk enroll) | -20030 | invalid status |
| -20022 | not enough seats | -20031 | student missing (status) |

## Why bulk processing is faster
PL/SQL and SQL run in two separate engines. A loop that executes `INSERT`/`UPDATE` once per row causes one **context switch** per row (N switches, N statement executions). 
- `BULK COLLECT` fetches all rows into a collection in **one** switch instead of one `FETCH` per row.
- `FORALL` sends the whole collection to the SQL engine in **one** switch and executes the statement for every element, avoiding per-row parse/bind/dispatch overhead.

Trade-offs: collections live in session memory (PGA), so very large result sets should be fetched with `BULK COLLECT ... LIMIT n` in batches; `FORALL` accepts a single DML statement; and without `SAVE EXCEPTIONS` the first error aborts the whole FORALL (rows already processed in it are rolled back by the statement-level rollback).

## Measured results (fill in from your own run)
Run `BEGIN performance_compare(20000); END;` and paste your numbers, then add the screenshot `test_performance_compare_output.png`.

| Rows | Operation | Row-by-row (cs) | FORALL (cs) | Speed-up |
|------|-----------|-----------------|-------------|----------|
| 20000 | INSERT | _ | _ | _ |
| 20000 | UPDATE | _ | _ | _ |

(cs = hundredths of a second; results vary with hardware and Oracle version.)
