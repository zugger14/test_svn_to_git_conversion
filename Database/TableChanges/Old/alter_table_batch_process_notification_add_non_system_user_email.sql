IF COL_LENGTH('batch_process_notifications', 'non_sys_user_email') IS NULL
BEGIN
    ALTER TABLE batch_process_notifications ADD non_sys_user_email VARCHAR(8000)
END
GO