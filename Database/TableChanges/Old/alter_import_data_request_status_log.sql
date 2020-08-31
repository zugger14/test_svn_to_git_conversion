IF COL_LENGTH('import_data_request_status_log', 'request_file_name') IS NOT NULL
BEGIN
	ALTER TABLE import_data_request_status_log ALTER COLUMN request_file_name VARCHAR(100)
	PRINT 'Column import_data_request_status_log.request_file_name altered.'
END
ELSE
BEGIN
	PRINT 'Column import_data_request_status_log.request_file_name does not exist.'
END
GO