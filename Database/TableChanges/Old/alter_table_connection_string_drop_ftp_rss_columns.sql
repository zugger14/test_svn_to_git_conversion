IF COL_LENGTH('connection_string','report_server_rss_path') IS NOT NULL
	ALTER TABLE connection_string DROP COLUMN report_server_rss_path
GO	
IF COL_LENGTH('connection_string','ftp_server_url') IS NOT NULL
	ALTER TABLE connection_string DROP COLUMN ftp_server_url
GO
IF COL_LENGTH('connection_string','ftp_server_rss_path') IS NOT NULL
	ALTER TABLE connection_string DROP COLUMN ftp_server_rss_path
GO

IF COL_LENGTH('connection_string','ftp_server_user_name') IS NOT NULL
	ALTER TABLE connection_string DROP COLUMN ftp_server_user_name
GO
IF COL_LENGTH('connection_string','ftp_server_password') IS NOT NULL
	ALTER TABLE connection_string DROP COLUMN ftp_server_password
GO
IF COL_LENGTH('connection_string','ftp_remote_file_path') IS NOT NULL
	ALTER TABLE connection_string DROP COLUMN ftp_remote_file_path
GO
IF COL_LENGTH('connection_string','ftp_local_file_path') IS NOT NULL
	ALTER TABLE connection_string DROP COLUMN ftp_local_file_path
GO