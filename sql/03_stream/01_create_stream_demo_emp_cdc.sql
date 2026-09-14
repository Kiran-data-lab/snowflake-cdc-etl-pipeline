-- ============================================================
-- Project: Snowflake CDC-Based ETL Pipeline
-- Object : STREAM_DEMO_EMP_CDC
-- Purpose: Capture INSERT, UPDATE and DELETE changes
-- ============================================================
create or replace stream STREAM_DEMO_EMP_CDC on table STREAM_DEMO_EMP;
