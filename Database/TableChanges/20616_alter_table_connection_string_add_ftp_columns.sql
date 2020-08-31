IF COL_LENGTH('connection_string','export_ftp_url') IS NULL
	ALTER TABLE connection_string ADD export_ftp_url NVARCHAR(1024)
GO
IF COL_LENGTH('connection_string','export_ftp_username') IS NULL  
	ALTER TABLE connection_string ADD export_ftp_username NVARCHAR(1024)
GO

IF COL_LENGTH('connection_string','export_ftp_password') IS NULL
	ALTER TABLE connection_string ADD export_ftp_password varbinary(1024)
GO

IF COL_LENGTH('connection_string','import_ftp_url') IS NULL 
	ALTER TABLE connection_string ADD import_ftp_url NVARCHAR(1024)
GO
IF COL_LENGTH('connection_string','import_ftp_username') IS NULL 
	ALTER TABLE connection_string ADD import_ftp_username NVARCHAR(1024)
GO

IF COL_LENGTH('connection_string','import_ftp_password') IS NULL 
	ALTER TABLE connection_string ADD import_ftp_password varbinary(1024)
GO

IF COL_LENGTH('connection_string','enable_ssl') IS NULL 
	ALTER TABLE connection_string ADD enable_ssl BIT
GO

IF COL_LENGTH('connection_string','import_remote_directory') IS NULL 
	ALTER TABLE connection_string ADD import_remote_directory VARCHAR(1024)
GO

IF COL_LENGTH('connection_string','export_remote_directory') IS NULL 
	ALTER TABLE connection_string ADD export_remote_directory VARCHAR(1024)
GO

IF COL_LENGTH('connection_string','use_sftp') IS NULL 
	ALTER TABLE connection_string ADD use_sftp BIT
GO