IF COL_LENGTH('batch_process_notifications', 'csv_file_path') IS NULL
BEGIN
    ALTER TABLE batch_process_notifications ADD csv_file_path VARCHAR(500)
END
GO