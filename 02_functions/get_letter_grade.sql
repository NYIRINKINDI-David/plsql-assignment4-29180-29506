-- get_letter_grade : converts a numeric score (0-100) to a letter grade.
-- NULL in -> NULL out (no grade yet). Out-of-range input raises an error
-- instead of returning a misleading letter.
CREATE OR REPLACE FUNCTION get_letter_grade (
  p_score IN NUMBER
) RETURN VARCHAR2 DETERMINISTIC IS
BEGIN
  IF p_score IS NULL THEN
    RETURN NULL;
  ELSIF p_score < 0 OR p_score > 100 THEN
    RAISE_APPLICATION_ERROR(-20060, 'Invalid score ' || p_score || ': must be between 0 and 100');
  ELSIF p_score >= 90 THEN RETURN 'A';
  ELSIF p_score >= 80 THEN RETURN 'B';
  ELSIF p_score >= 70 THEN RETURN 'C';
  ELSIF p_score >= 60 THEN RETURN 'D';
  ELSE RETURN 'F';
  END IF;
END get_letter_grade;
/
SHOW ERRORS
