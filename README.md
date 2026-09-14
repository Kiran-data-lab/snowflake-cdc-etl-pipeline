# Snowflake CDC-Based ETL Pipeline

## Project Overview

This project demonstrates a hands-on incremental ETL pipeline implemented using Snowflake.

The pipeline captures INSERT, UPDATE and DELETE changes from a source employee table using Snowflake Streams, persists CDC events into an audit layer, processes incremental batches into a current-state target table, maintains a watermark for incremental processing, and automates execution using Snowflake Tasks.

The project also demonstrates transaction management, rollback, failure recovery and retry processing.

---

## Architecture

Source Table
    ↓
Snowflake Stream
    ↓
CDC Audit Table
    ↓
Stored Procedure
    ↓
Watermark / Control Table
    ↓
Stored Procedure
    ↓
Current-State Target
    ↓
ETL Monitoring

Snowflake Task automates the pipeline execution.

---

## Technologies

- Snowflake
- SQL
- Snowflake Streams
- Snowflake Tasks
- Snowflake Scripting
- Stored Procedures
- MERGE
- Transactions
- CDC
- ETL Audit
- Watermark-based Incremental Processing
- Error Handling
- ETL Monitoring

---

## Pipeline Components

| Component | Purpose |
|---|---|
| STREAM_DEMO_EMP | Source employee table |
| STREAM_DEMO_EMP_CDC | Captures source changes |
| EMP_AUDIT | Persistent CDC audit layer |
| ETL_CONTROL | Maintains processing watermark |
| ETL_JOB_RUN | Tracks ETL execution |
| EMP_CURRENT | Current-state target table |
| SP_LOAD_STREAM_TO_AUDIT | Loads Stream changes into audit |
| SP_PROCESS_EMP_CDC | Processes incremental CDC |
| TASK_PROCESS_EMP_CDC | Automates ETL execution |
| DATABASE_LOG | Procedure/job logging |

---

## CDC Processing

The pipeline handles:

- INSERT
- UPDATE
- DELETE

Snowflake Streams represent an UPDATE as a DELETE plus INSERT pair.

The implementation uses:

- METADATA$ACTION
- METADATA$ISUPDATE

to distinguish update-generated DELETE records from genuine DELETE operations.

---

## Incremental Processing

The pipeline uses an AUDIT_ID watermark.

Example:

    LAST_AUDIT_ID = 905

The next processing batch reads:

    AUDIT_ID > 905

After successful processing:

    LAST_AUDIT_ID = 1003

This prevents already processed audit records from being processed again.

---

## Transaction and Failure Recovery

The ETL processing procedure uses transactions.

Processing follows:

    BEGIN TRANSACTION
        ↓
    Process CDC records
        ↓
    Update target
        ↓
    Update watermark
        ↓
    COMMIT

If an error occurs:

    ERROR
        ↓
    ROLLBACK
        ↓
    Watermark remains unchanged
        ↓
    Next Task execution retries the batch

A controlled failure test was performed successfully.

Before failure:

    LAST_AUDIT_ID = 905

After failure:

    LAST_AUDIT_ID = 905

After successful retry:

    LAST_AUDIT_ID = 1003

---

## Automation

The pipeline is automated using a Snowflake Task.

The Task executes every minute and performs:

    Stream → Audit → Processing → Target

---

## Monitoring

The project uses:

- ETL_CONTROL
- ETL_JOB_RUN
- DATABASE_LOG
- Snowflake TASK_HISTORY

to monitor pipeline execution and failures.

---

## Testing Performed

The project has been tested for:

1. INSERT processing
2. UPDATE processing
3. DELETE processing
4. Multiple CDC records
5. Watermark-based incremental processing
6. Transaction rollback
7. Failure recovery
8. Automatic Task retry
9. Successful watermark advancement

---

## Key Learning Outcomes

This project demonstrates practical experience with:

- Snowflake CDC
- Incremental ETL
- Streams
- Tasks
- Stored Procedures
- MERGE
- Watermark design
- Transaction management
- Error handling
- Retry processing
- Audit logging
- ETL monitoring

---

## Project Status

Version 1.0

Core CDC-based ETL pipeline implemented and tested.

Future enhancements may include additional monitoring, task dependency management, data quality checks and advanced orchestration patterns.
