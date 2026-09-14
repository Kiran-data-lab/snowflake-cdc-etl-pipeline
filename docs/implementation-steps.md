# Implementation Steps

## Step 1 — Create Snowflake Environment

Database:

    PRACTICE_DB

Schema:

    TRAINING

Warehouse:

    COMPUTE_WH

---

## Step 2 — Create Source Table

Source table:

    STREAM_DEMO_EMP

The table represents the operational employee source.

Columns:

- EMP_ID
- EMP_NAME
- CITY
- SALARY

---

## Step 3 — Create Snowflake Stream

Stream:

    STREAM_DEMO_EMP_CDC

The Stream captures changes occurring on STREAM_DEMO_EMP.

CDC operations tested:

- INSERT
- UPDATE
- DELETE

---

## Step 4 — Understand Stream Metadata

The implementation uses:

    METADATA$ACTION

and

    METADATA$ISUPDATE

An UPDATE produces:

    DELETE + INSERT

with ISUPDATE = TRUE.

A genuine DELETE produces:

    DELETE

with ISUPDATE = FALSE.

---

## Step 5 — Create CDC Audit Layer

Table:

    EMP_AUDIT

The audit table persists CDC events from the Stream.

Important columns include:

- AUDIT_ID
- EMP_ID
- EMP_NAME
- CITY
- SALARY
- CDC_ACTION
- IS_UPDATE
- AUDIT_TIME

---

## Step 6 — Create Stream-to-Audit Procedure

Procedure:

    SP_LOAD_STREAM_TO_AUDIT()

Purpose:

Move CDC records from the Snowflake Stream into EMP_AUDIT.

This creates a persistent CDC history.

---

## Step 7 — Create ETL Control Table

Table:

    ETL_CONTROL

Important columns:

- JOB_NAME
- LAST_AUDIT_ID
- LAST_RUN_TIME
- STATUS

The table stores the watermark of the last successfully processed audit record.

---

## Step 8 — Create Current-State Target

Table:

    EMP_CURRENT

Purpose:

Maintain the latest state of each employee.

---

## Step 9 — Create ETL Processing Procedure

Procedure:

    SP_PROCESS_EMP_CDC()

Processing flow:

1. Read LAST_AUDIT_ID.
2. Identify new records from EMP_AUDIT.
3. Create a temporary processing batch.
4. Process INSERT and UPDATE records.
5. Process genuine DELETE records.
6. Update the target.
7. Update the watermark.
8. Commit the transaction.

---

## Step 10 — Add Transaction Handling

The processing procedure uses:

    BEGIN TRANSACTION

and

    COMMIT

If processing fails:

    ROLLBACK

This prevents partial ETL processing.

---

## Step 11 — Create ETL Job Run Tracking

Table:

    ETL_JOB_RUN

Purpose:

Track:

- Run ID
- Job name
- Start time
- End time
- Start audit ID
- End audit ID
- Record count
- Status
- Error message

---

## Step 12 — Automate Using Snowflake Task

Task:

    TASK_PROCESS_EMP_CDC

Schedule:

    Every 1 minute

The Task executes:

    SP_LOAD_STREAM_TO_AUDIT()

followed by:

    SP_PROCESS_EMP_CDC()

---

## Step 13 — Test Incremental Processing

Tested:

- New employee insertion
- Employee salary update
- Employee deletion
- Multiple CDC records

---

## Step 14 — Test Failure Recovery

A controlled failure was introduced.

Before failure:

    LAST_AUDIT_ID = 905

The transaction was rolled back.

The watermark remained:

    LAST_AUDIT_ID = 905

---

## Step 15 — Test Automatic Retry

The Task was resumed.

The unprocessed audit records were retried.

The target was successfully updated.

Final watermark:

    LAST_AUDIT_ID = 1003

Status:

    SUCCESS

---

## Final Pipeline

    SOURCE
       ↓
    STREAM
       ↓
    AUDIT
       ↓
    WATERMARK
       ↓
    STORED PROCEDURE
       ↓
    TARGET
       ↓
    MONITORING

    TASK
       ↓
    AUTOMATION
