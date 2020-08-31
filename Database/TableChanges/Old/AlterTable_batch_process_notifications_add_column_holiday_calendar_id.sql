IF COL_LENGTH('batch_process_notifications', 'holiday_calendar_id') IS NULL
BEGIN
    ALTER TABLE batch_process_notifications ADD holiday_calendar_id INT NULL
END
GO