# Snowflake ETL Pipeline Architecture

## High-Level Architecture

```text
                    SOURCE
                      |
                      v
             STREAM_DEMO_EMP
                      |
                      v
          STREAM_DEMO_EMP_CDC                      
                      |
                      v
                 EMP_AUDIT
                      |
                      v
          SP_LOAD_STREAM_TO_AUDIT
                      |
                      v
               ETL_CONTROL
              (Watermark)
                      |
                      v
            SP_PROCESS_EMP_CDC
                      |
                      v
                 EMP_CURRENT
                      |
                      v
                 ETL Monitoring


       TASK_PROCESS_EMP_CDC
                 |
                 +----> SP_LOAD_STREAM_TO_AUDIT
                 |
                 +----> SP_PROCESS_EMP_CDC

Source Layer: The source table represents employee operational data.
Object: STREAM_DEMO_EMP

CDC Layer: Snowflake Stream: STREAM_DEMO_EMP_CDC
Captures changes from the source.

Audit Layer
Table:EMP_AUDIT
Purpose:Persist Stream changes so they can be processed incrementally and retained for auditing.

Control Layer
Table: ETL_CONTROL
Purpose: Maintain the watermark.
Example: LAST_AUDIT_ID = 1003

Processing Layer
Procedure: SP_PROCESS_EMP_CDC()
Responsible for applying incremental CDC changes to the target.

Target Layer
Table:EMP_CURRENT
Contains the current state of employees.

Automation Layer
Task:TASK_PROCESS_EMP_CDC
Runs the ETL automatically.

Monitoring Layer
Monitoring objects include:
ETL_CONTROL
ETL_JOB_RUN
DATABASE_LOG
TASK_HISTORY
Failure Recovery

The pipeline uses transaction control. If processing fails: ROLLBACK
The watermark is not advanced.
The next execution can retry the unprocessed audit records.

