-- ============================================================
-- CDC UPDATE Test
-- ============================================================

UPDATE PRACTICE_DB.TRAINING.STREAM_DEMO_EMP
SET SALARY = 800000
WHERE EMP_ID = 101;

SELECT *
FROM PRACTICE_DB.TRAINING.STREAM_DEMO_EMP_CDC;
