-- ============================================================
-- Project: Snowflake CDC-Based ETL Pipeline
-- Object : ETL_CONTROL
-- Purpose: Maintain ETL processing watermark and status
-- ============================================================

create or replace TABLE ETL_CONTROL (
	JOB_NAME VARCHAR(16777216),
	LAST_AUDIT_ID NUMBER(38,0),
	LAST_RUN_TIME TIMESTAMP_NTZ(9),
	STATUS VARCHAR(16777216)
);
