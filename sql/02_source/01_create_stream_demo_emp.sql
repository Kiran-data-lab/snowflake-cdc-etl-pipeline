-- ============================================================
-- Project: Snowflake CDC-Based ETL Pipeline
-- Object : STREAM_DEMO_EMP
-- Purpose: Source employee table
-- ============================================================
create or replace TABLE STREAM_DEMO_EMP (
	EMP_ID NUMBER(38,0),
	EMP_NAME VARCHAR(16777216),
	CITY VARCHAR(16777216),
	SALARY NUMBER(10,2)
);
