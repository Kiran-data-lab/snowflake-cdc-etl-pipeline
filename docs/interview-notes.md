# Interview Notes

## How would you explain this project?

I built a CDC-based incremental ETL pipeline in Snowflake.
The source employee table is monitored using a Snowflake Stream.
Changes are persisted into an audit table.
A watermark maintained in ETL_CONTROL identifies the last successfully processed audit record.
A Snowflake Task automates the process.
A stored procedure processes the incremental batch and updates the current-state target using MERGE.
Transactions are used so that target changes and watermark advancement are handled safely.
I also implemented and tested failure recovery and retry processing.

---
## Why did you use Streams?
Streams provide Change Data Capture information from source table changes.
They allow the ETL process to identify only changed records instead of repeatedly processing the complete source table.

---
## How do you handle UPDATE?
Snowflake Streams represent an UPDATE as:
DELETE + INSERT
Both records have:
METADATA$ISUPDATE = TRUE
The processing logic uses this metadata so that the DELETE portion of an UPDATE does not incorrectly delete the current target record.

---
## How do you handle a real DELETE?
A genuine DELETE has:
METADATA$ACTION = DELETE and METADATA$ISUPDATE = FALSE
Those records are used to delete the corresponding target record.

---
## Why use an audit table?
The Stream is used as the CDC source.
EMP_AUDIT provides persistent CDC history and separates CDC capture from downstream processing.

---
## Why use a watermark?
The watermark identifies the last successfully processed audit record.
Example:
    LAST_AUDIT_ID = 905
The next batch processes:
    AUDIT_ID > 905

---
## What happens when ETL fails?
The transaction is rolled back.
The watermark is not advanced.
The unprocessed records remain available in the audit layer.
The next Task execution can retry the batch.

---
## How did you test failure recovery?
I intentionally introduced an error during a transaction.
The target change was rolled back.
The watermark remained at 905.
After the Task was resumed, the same unprocessed records were successfully processed.
The watermark then advanced to 1003.

---
## Why use a Snowflake Task?
The Task automates the ETL process so that procedures do not have to be manually executed.

---
## Technologies Used
Snowflake
SQL
Streams
Tasks
Stored Procedures
MERGE
Transactions
CDC
Watermark processing
Audit logging
ETL monitoring
