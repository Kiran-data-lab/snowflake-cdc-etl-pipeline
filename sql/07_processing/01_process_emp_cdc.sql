-- ============================================================
-- Project: Snowflake CDC-Based ETL Pipeline
-- Object : SP_PROCESS_EMP_CDC
-- Purpose:
--   Process incremental CDC records from EMP_AUDIT
--   into EMP_CURRENT using watermark-based processing.
--
-- Key features:
--   - Incremental processing
--   - MERGE
--   - DELETE handling
--   - Watermark management
--   - Transactions
--   - Rollback / error handling
-- ============================================================

CREATE OR REPLACE PROCEDURE "SP_PROCESS_EMP_CDC"()
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS '
DECLARE
    V_JOB_NAME STRING DEFAULT ''EMP_CURRENT_LOAD'';
    V_RUN_ID NUMBER;
    V_LAST_AUDIT_ID NUMBER;
    V_BATCH_END_ID NUMBER;
    V_RECORD_COUNT NUMBER;
BEGIN

    ----------------------------------------------------------------
    -- 1. Get current watermark
    ----------------------------------------------------------------
    SELECT LAST_AUDIT_ID
    INTO :V_LAST_AUDIT_ID
    FROM PRACTICE_DB.TRAINING.ETL_CONTROL
    WHERE JOB_NAME = :V_JOB_NAME;


    ----------------------------------------------------------------
    -- 2. Create a fixed batch BEFORE starting transaction
    ----------------------------------------------------------------
    CREATE OR REPLACE TEMP TABLE TEMP_EMP_CDC_BATCH AS
    SELECT
        AUDIT_ID,
        EMP_ID,
        EMP_NAME,
        CITY,
        SALARY,
        CDC_ACTION,
        IS_UPDATE,
        AUDIT_TIME
    FROM PRACTICE_DB.TRAINING.EMP_AUDIT
    WHERE AUDIT_ID > :V_LAST_AUDIT_ID;


    ----------------------------------------------------------------
    -- 3. Get batch information
    ----------------------------------------------------------------
    SELECT
        MAX(AUDIT_ID),
        COUNT(*)
    INTO
        :V_BATCH_END_ID,
        :V_RECORD_COUNT
    FROM TEMP_EMP_CDC_BATCH;


    ----------------------------------------------------------------
    -- 4. If nothing new, stop
    ----------------------------------------------------------------
    IF (V_RECORD_COUNT = 0) THEN

        RETURN ''NO NEW CDC RECORDS'';

    END IF;


    ----------------------------------------------------------------
    -- 5. Create JOB RUN audit record
    ----------------------------------------------------------------
    INSERT INTO PRACTICE_DB.TRAINING.ETL_JOB_RUN
    (
        JOB_NAME,
        START_TIME,
        START_AUDIT_ID,
        STATUS
    )
    VALUES
    (
        :V_JOB_NAME,
        CURRENT_TIMESTAMP(),
        :V_LAST_AUDIT_ID + 1,
        ''RUNNING''
    );


    ----------------------------------------------------------------
    -- 6. Get RUN_ID
    ----------------------------------------------------------------
    SELECT MAX(RUN_ID)
    INTO :V_RUN_ID
    FROM PRACTICE_DB.TRAINING.ETL_JOB_RUN
    WHERE JOB_NAME = :V_JOB_NAME
      AND STATUS = ''RUNNING'';


    ----------------------------------------------------------------
    -- 7. START TRANSACTION
    ----------------------------------------------------------------
    BEGIN TRANSACTION;


    ----------------------------------------------------------------
    -- 8. Process INSERT + UPDATE new images
    --
    -- INSERT + TRUE  = new version of UPDATE
    -- INSERT + FALSE = genuine INSERT
    ----------------------------------------------------------------
    MERGE INTO PRACTICE_DB.TRAINING.EMP_CURRENT T
    USING
    (
        SELECT
            EMP_ID,
            EMP_NAME,
            CITY,
            SALARY,
            AUDIT_TIME
        FROM TEMP_EMP_CDC_BATCH
        WHERE CDC_ACTION = ''INSERT''
        QUALIFY ROW_NUMBER() OVER
        (
            PARTITION BY EMP_ID
            ORDER BY AUDIT_ID DESC
        ) = 1
    ) S
    ON T.EMP_ID = S.EMP_ID

    WHEN MATCHED THEN UPDATE SET
        T.EMP_NAME = S.EMP_NAME,
        T.CITY = S.CITY,
        T.SALARY = S.SALARY,
        T.LAST_UPDATED = S.AUDIT_TIME

    WHEN NOT MATCHED THEN INSERT
    (
        EMP_ID,
        EMP_NAME,
        CITY,
        SALARY,
        LAST_UPDATED
    )
    VALUES
    (
        S.EMP_ID,
        S.EMP_NAME,
        S.CITY,
        S.SALARY,
        S.AUDIT_TIME
    );


    ----------------------------------------------------------------
    -- 9. Process REAL DELETE
    --
    -- DELETE + FALSE = actual source deletion
    ----------------------------------------------------------------
    DELETE FROM PRACTICE_DB.TRAINING.EMP_CURRENT T
    USING TEMP_EMP_CDC_BATCH B
    WHERE T.EMP_ID = B.EMP_ID
      AND B.CDC_ACTION = ''DELETE''
      AND B.IS_UPDATE = FALSE;


    ----------------------------------------------------------------
    -- 10. Advance watermark
    ----------------------------------------------------------------
    UPDATE PRACTICE_DB.TRAINING.ETL_CONTROL
    SET
        LAST_AUDIT_ID = :V_BATCH_END_ID,
        LAST_RUN_TIME = CURRENT_TIMESTAMP(),
        STATUS = ''SUCCESS''
    WHERE JOB_NAME = :V_JOB_NAME;


    ----------------------------------------------------------------
    -- 11. Mark JOB RUN successful
    ----------------------------------------------------------------
    UPDATE PRACTICE_DB.TRAINING.ETL_JOB_RUN
    SET
        END_TIME = CURRENT_TIMESTAMP(),
        END_AUDIT_ID = :V_BATCH_END_ID,
        RECORD_COUNT = :V_RECORD_COUNT,
        STATUS = ''SUCCESS''
    WHERE RUN_ID = :V_RUN_ID;


    ----------------------------------------------------------------
    -- 12. Commit everything
    ----------------------------------------------------------------
    COMMIT;


    RETURN
        ''SUCCESS. RUN_ID='' || V_RUN_ID ||
        '', RECORDS='' || V_RECORD_COUNT ||
        '', END_AUDIT_ID='' || V_BATCH_END_ID;


EXCEPTION
    WHEN OTHER THEN

        ----------------------------------------------------------------
        -- Roll back target + control changes
        ----------------------------------------------------------------
        ROLLBACK;


        ----------------------------------------------------------------
        -- Record failure after rollback
        ----------------------------------------------------------------
        UPDATE PRACTICE_DB.TRAINING.ETL_JOB_RUN
        SET
            END_TIME = CURRENT_TIMESTAMP(),
            END_AUDIT_ID = :V_BATCH_END_ID,
            RECORD_COUNT = :V_RECORD_COUNT,
            STATUS = ''FAILED'',
            ERROR_MESSAGE = SQLERRM
        WHERE RUN_ID = :V_RUN_ID;


        RETURN
            ''FAILED. RUN_ID='' || V_RUN_ID ||
            '', ERROR='' || SQLERRM;

END;
';
