-- ============================================================
-- Project: Snowflake CDC-Based ETL Pipeline
-- Object : SP_LOAD_STREAM_TO_AUDIT
-- Purpose: Persist Stream CDC records into EMP_AUDIT
-- ============================================================
CREATE OR REPLACE PROCEDURE "SP_LOAD_STREAM_TO_AUDIT"()
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS '
DECLARE
    V_COUNT NUMBER;
BEGIN

    INSERT INTO PRACTICE_DB.TRAINING.EMP_AUDIT
    (
        EMP_ID,
        EMP_NAME,
        CITY,
        SALARY,
        CDC_ACTION,
        IS_UPDATE,
        AUDIT_TIME
    )
    SELECT
        EMP_ID,
        EMP_NAME,
        CITY,
        SALARY,
        METADATA$ACTION,
        METADATA$ISUPDATE,
        CURRENT_TIMESTAMP()
    FROM PRACTICE_DB.TRAINING.STREAM_DEMO_EMP_CDC;

    SELECT COUNT(*)
    INTO :V_COUNT
    FROM PRACTICE_DB.TRAINING.EMP_AUDIT
    WHERE AUDIT_ID >
    (
        SELECT LAST_AUDIT_ID
        FROM PRACTICE_DB.TRAINING.ETL_CONTROL
        WHERE JOB_NAME = ''EMP_CURRENT_LOAD''
    );

    RETURN ''STREAM TO AUDIT SUCCESS. RECORDS='' || V_COUNT;

EXCEPTION
    WHEN OTHER THEN
        RETURN ''FAILED. ERROR='' || SQLERRM;
END;
';
