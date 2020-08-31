IF COL_LENGTH('batch_process_notifications', 'delimiter') IS NULL
BEGIN
    ALTER TABLE batch_process_notifications ADD delimiter VARCHAR(10)
END
GO

IF COL_LENGTH('batch_process_notifications', 'report_header') IS NULL
BEGIN
    ALTER TABLE batch_process_notifications ADD report_header VARCHAR(10)
END
GO