-- ============================================================
-- CDC DELETE Test
-- ============================================================

DELETE FROM PRACTICE_DB.TRAINING.STREAM_DEMO_EMP
WHERE EMP_ID = 121;

SELECT *
FROM PRACTICE_DB.TRAINING.STREAM_DEMO_EMP_CDC;
