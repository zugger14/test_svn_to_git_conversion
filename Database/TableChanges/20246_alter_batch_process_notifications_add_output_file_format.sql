IF COL_LENGTH('batch_process_notifications', 'output_file_format') IS NULL
BEGIN
    ALTER TABLE batch_process_notifications ADD output_file_format VARCHAR(6)
END
ELSE 
	PRINT 'Column already exists.'
GO

