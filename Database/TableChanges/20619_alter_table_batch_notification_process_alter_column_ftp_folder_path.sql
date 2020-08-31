IF COL_LENGTH(N'batch_process_notifications', 'ftp_folder_path') IS NOT NULL
BEGIN
	ALTER TABLE batch_process_notifications ALTER COLUMN ftp_folder_path VARCHAR (1024)
	PRINT 'Altered column ftp_folder_path.'
END