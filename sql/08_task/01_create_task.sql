-- ============================================================
-- Project: Snowflake CDC-Based ETL Pipeline
-- Object : TASK_PROCESS_EMP_CDC
-- Purpose: Automate the CDC ETL pipeline
-- ============================================================

create or replace task TASK_PROCESS_EMP_CDC
	warehouse=COMPUTE_WH
	schedule='1 MINUTE'
	as BEGIN
    CALL PRACTICE_DB.TRAINING.SP_LOAD_STREAM_TO_AUDIT();
    CALL PRACTICE_DB.TRAINING.SP_PROCESS_EMP_CDC();
END;
