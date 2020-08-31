IF COL_LENGTH('alert_sql', 'sql_id') IS NOT NULL
BEGIN
    ALTER TABLE alert_sql DROP COLUMN sql_id
END
GO
IF COL_LENGTH('alert_sql', 'sql_statement') IS NULL
BEGIN
    ALTER TABLE alert_sql ADD sql_statement VARCHAR(8000)
END
GO
IF COL_LENGTH('alert_sql', 'alert_sql_name') IS NULL
BEGIN
    ALTER TABLE alert_sql ADD alert_sql_name VARCHAR(100)
END
GO

IF COL_LENGTH('alert_reports', 'report_writer_id') IS NOT NULL
BEGIN
    EXEC SP_RENAME 'alert_reports.[report_writer_id]' , 'paramset_hash', 'COLUMN'
END
GO

IF COL_LENGTH('alert_reports', 'paramset_hash') IS NOT NULL
BEGIN
    ALTER TABLE alert_reports ALTER COLUMN paramset_hash VARCHAR(8000)
END
GO
IF COL_LENGTH('message_board', 'is_alert') IS NULL
BEGIN
    ALTER TABLE message_board ADD is_alert CHAR(1) NULL
END
GO
IF COL_LENGTH('message_board', 'is_alert_processed') IS NULL
BEGIN
    ALTER TABLE message_board ADD is_alert_processed CHAR(1) NULL
END
GO
IF COL_LENGTH('alert_workflows', 'workflow_trigger') IS NULL
BEGIN
    ALTER TABLE alert_workflows ADD workflow_trigger CHAR(1) NULL
END
GO