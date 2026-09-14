-- ============================================================
-- Project: Snowflake CDC-Based ETL Pipeline
-- Object : ETL_JOB_RUN
-- Purpose: Track ETL execution history
-- ============================================================
create or replace TABLE ETL_JOB_RUN (
	RUN_ID NUMBER(38,0) autoincrement start 1 increment 1 noorder,
	JOB_NAME VARCHAR(16777216),
	START_TIME TIMESTAMP_NTZ(9),
	END_TIME TIMESTAMP_NTZ(9),
	START_AUDIT_ID NUMBER(38,0),
	END_AUDIT_ID NUMBER(38,0),
	RECORD_COUNT NUMBER(38,0),
	STATUS VARCHAR(16777216),
	ERROR_MESSAGE VARCHAR(16777216)
);
