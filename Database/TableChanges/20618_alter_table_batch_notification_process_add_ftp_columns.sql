IF COL_LENGTH('batch_process_notifications', 'is_ftp') IS NULL
BEGIN
ALTER TABLE batch_process_notifications ADD is_ftp BIT DEFAULT 0
END
ELSE
BEGIN
	PRINT 'Column is_ftp EXISTS'
END

IF COL_LENGTH('batch_process_notifications', 'ftp_url') IS NULL
BEGIN
ALTER TABLE batch_process_notifications ADD ftp_url NVARCHAR(2048)
END
ELSE
BEGIN
	PRINT 'Column ftp_url EXISTS'
END

IF COL_LENGTH('batch_process_notifications', 'ftp_username') IS NULL
BEGIN
ALTER TABLE batch_process_notifications ADD ftp_username NVARCHAR(2048)
END
ELSE
BEGIN
	PRINT 'Column ftp_username EXISTS'
END

IF COL_LENGTH('batch_process_notifications', 'ftp_password') IS NULL
BEGIN
ALTER TABLE batch_process_notifications ADD ftp_password VARBINARY(1024)
END
ELSE
BEGIN
	PRINT 'Column ftp_password EXISTS'
END

IF COL_LENGTH('batch_process_notifications', 'ftp_folder_path') IS NULL
BEGIN
ALTER TABLE batch_process_notifications ADD ftp_folder_path CHAR(1)
END
ELSE
BEGIN
	PRINT 'Column ftp_folder_path EXISTS'
END