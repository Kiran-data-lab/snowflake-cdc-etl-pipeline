-- ============================================================
-- Project: Snowflake CDC-Based ETL Pipeline
-- Object : EMP_AUDIT
-- Purpose: Persist CDC events from Snowflake Stream
-- ============================================================
create or replace TABLE EMP_AUDIT (
	AUDIT_ID NUMBER(38,0) autoincrement start 1 increment 1 noorder,
	EMP_ID NUMBER(38,0),
	EMP_NAME VARCHAR(16777216),
	CITY VARCHAR(16777216),
	SALARY NUMBER(10,2),
	CDC_ACTION VARCHAR(16777216),
	IS_UPDATE BOOLEAN,
	AUDIT_TIME TIMESTAMP_NTZ(9)
);
