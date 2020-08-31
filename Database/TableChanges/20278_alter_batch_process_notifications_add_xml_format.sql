IF COL_LENGTH('batch_process_notifications', 'xml_format') IS NULL
BEGIN
    ALTER TABLE batch_process_notifications ADD xml_format INT
END
ELSE 
	PRINT 'Column already exists.'
GO

