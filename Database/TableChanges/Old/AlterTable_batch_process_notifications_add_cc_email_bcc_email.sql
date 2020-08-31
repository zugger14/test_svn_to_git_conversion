IF COL_LENGTH('batch_process_notifications', 'bcc_email') IS NULL
BEGIN
    ALTER TABLE batch_process_notifications ADD bcc_email varchar(5000)
END
GO

IF COL_LENGTH('batch_process_notifications', 'cc_email') IS NULL
BEGIN
    ALTER TABLE batch_process_notifications ADD cc_email varchar(5000)
END
GO