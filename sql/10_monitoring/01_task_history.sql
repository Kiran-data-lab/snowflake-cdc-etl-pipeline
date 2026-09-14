-- ============================================================
-- Snowflake Task Monitoring
-- ============================================================

SELECT
    NAME,
    STATE,
    SCHEDULED_TIME,
    QUERY_START_TIME,
    COMPLETED_TIME,
    ERROR_CODE,
    ERROR_MESSAGE,
    QUERY_ID
FROM TABLE(
    SNOWFLAKE.INFORMATION_SCHEMA.TASK_HISTORY(
        TASK_NAME => 'TASK_PROCESS_EMP_CDC',
        RESULT_LIMIT => 10
    )
)
ORDER BY SCHEDULED_TIME DESC;
