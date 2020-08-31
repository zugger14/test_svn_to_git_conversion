-- Add compress_file field with default value 'n'
IF COL_LENGTH('batch_process_notifications', 'compress_file') IS NULL
BEGIN
    ALTER TABLE batch_process_notifications ADD compress_file CHAR(1) DEFAULT 'n'
END
ELSE 
	PRINT 'Column already exists.'
GO

