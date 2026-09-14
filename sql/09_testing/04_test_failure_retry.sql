-- ============================================================
-- Failure and Retry Test
-- ============================================================

-- STEP 1
-- Suspend the automated Task before preparing the test.

-- STEP 2
-- Create new CDC records.

-- STEP 3
-- Load Stream records into EMP_AUDIT.

-- STEP 4
-- Confirm the watermark has not changed.

-- STEP 5
-- Execute the controlled failure procedure.

-- STEP 6
-- Verify EMP_CURRENT was rolled back.

-- STEP 7
-- Verify ETL_CONTROL watermark remained unchanged.

-- STEP 8
-- Resume the Task.

-- STEP 9
-- Verify the CDC batch was successfully retried.

-- STEP 10
-- Verify the watermark advanced after successful processing.

CREATE OR REPLACE PROCEDURE "SP_TEST_ETL_FAILURE"()
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS '
DECLARE
    V_LAST_AUDIT_ID NUMBER;
BEGIN

    SELECT LAST_AUDIT_ID
    INTO :V_LAST_AUDIT_ID
    FROM PRACTICE_DB.TRAINING.ETL_CONTROL
    WHERE JOB_NAME = ''EMP_CURRENT_LOAD'';

    BEGIN TRANSACTION;

    -- Deliberate target change
    UPDATE PRACTICE_DB.TRAINING.EMP_CURRENT
    SET SALARY = 999999
    WHERE EMP_ID = 101;

    -- Deliberate failure
    SELECT 1 / 0;

    -- This should never execute
    UPDATE PRACTICE_DB.TRAINING.ETL_CONTROL
    SET LAST_AUDIT_ID = 1003,
        LAST_RUN_TIME = CURRENT_TIMESTAMP(),
        STATUS = ''SUCCESS''
    WHERE JOB_NAME = ''EMP_CURRENT_LOAD'';

    COMMIT;

    RETURN ''SUCCESS'';

EXCEPTION
    WHEN OTHER THEN
        ROLLBACK;

        RETURN ''EXPECTED FAILURE: '' || SQLERRM;
END;
';
