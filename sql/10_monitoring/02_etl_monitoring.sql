-- ============================================================
-- ETL Control Monitoring
-- ============================================================

SELECT
    JOB_NAME,
    LAST_AUDIT_ID,
    LAST_RUN_TIME,
    STATUS
FROM PRACTICE_DB.TRAINING.ETL_CONTROL
ORDER BY JOB_NAME;

-- ============================================================
-- ETL Job Execution History
-- ============================================================

SELECT *
FROM PRACTICE_DB.TRAINING.ETL_JOB_RUN
ORDER BY RUN_ID DESC;
