-- ============================================================
-- Project: Snowflake CDC-Based ETL Pipeline
-- Object : EMP_CURRENT
-- Purpose: Maintain current employee state
-- ============================================================
create or replace TABLE EMP_CURRENT (
	EMP_ID NUMBER(38,0),
	EMP_NAME VARCHAR(16777216),
	CITY VARCHAR(16777216),
	SALARY NUMBER(10,2),
	LAST_UPDATED TIMESTAMP_NTZ(9)
);
