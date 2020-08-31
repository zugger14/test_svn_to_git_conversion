IF COL_LENGTH('connection_string', 'document_path') IS NULL
BEGIN
    ALTER TABLE connection_string ADD document_path VARCHAR(300) NULL
END
ELSE
BEGIN
    PRINT 'document_path Already Exists.'
END 
GO

IF COL_LENGTH('connection_string', 'report_server_url') IS NULL
BEGIN
    ALTER TABLE connection_string ADD report_server_url VARCHAR(300) NULL
END
ELSE
BEGIN
    PRINT 'report_server_url Already Exists.'
END 
GO

IF COL_LENGTH('connection_string', 'report_server_rss_path') IS NULL
BEGIN
    ALTER TABLE connection_string ADD report_server_rss_path VARCHAR(300) NULL
END
ELSE
BEGIN
    PRINT 'report_server_rss_path Already Exists.'
END 
GO

IF COL_LENGTH('connection_string', 'report_folder') IS NULL
BEGIN
    ALTER TABLE connection_string ADD report_folder VARCHAR(300) NULL
END
ELSE
BEGIN
    PRINT 'report_folder Already Exists.'
END 
GO

IF COL_LENGTH('connection_string', 'report_server_user_name') IS NULL
BEGIN
    ALTER TABLE connection_string ADD report_server_user_name VARCHAR(100) NULL
END
ELSE
BEGIN
    PRINT 'report_server_user_name Already Exists.'
END 
GO
IF COL_LENGTH('connection_string', 'report_server_password') IS NULL
BEGIN
    ALTER TABLE connection_string ADD report_server_password VARCHAR(100) NULL
END
ELSE
BEGIN
    PRINT 'report_server_password Already Exists.'
END 
GO

IF COL_LENGTH('connection_string', 'report_server_domain') IS NULL
BEGIN
    ALTER TABLE connection_string ADD report_server_domain VARCHAR(200) NULL
END
ELSE
BEGIN
    PRINT 'report_server_domain Already Exists.'
END 
GO

IF COL_LENGTH('connection_string', 'report_server_datasource_name') IS NULL
BEGIN
    ALTER TABLE connection_string ADD report_server_datasource_name VARCHAR(200) NULL
END
ELSE
BEGIN
    PRINT 'report_server_datasource_name Already Exists.'
END 
GO

IF COL_LENGTH('connection_string', 'report_server_target_folder') IS NULL
BEGIN
    ALTER TABLE connection_string ADD report_server_target_folder VARCHAR(200) NULL
END
ELSE
BEGIN
    PRINT 'report_server_target_folder Already Exists.'
END 
GO

IF COL_LENGTH('connection_string', 'ftp_server_url') IS NULL
BEGIN
    ALTER TABLE connection_string ADD ftp_server_url VARCHAR(300) NULL
END
ELSE
BEGIN
    PRINT 'ftp_server_url Already Exists.'
END 
GO

IF COL_LENGTH('connection_string', 'ftp_server_rss_path') IS NULL
BEGIN
    ALTER TABLE connection_string ADD ftp_server_rss_path VARCHAR(300) NULL
END
ELSE
BEGIN
    PRINT 'ftp_server_rss_path Already Exists.'
END 
GO

IF COL_LENGTH('connection_string', 'ftp_server_user_name') IS NULL
BEGIN
    ALTER TABLE connection_string ADD ftp_server_user_name VARCHAR(100) NULL
END
ELSE
BEGIN
    PRINT 'ftp_server_user_name Already Exists.'
END 
GO
IF COL_LENGTH('connection_string', 'ftp_server_password') IS NULL
BEGIN
    ALTER TABLE connection_string ADD ftp_server_password VARBINARY(1000) NULL
END
ELSE
BEGIN
    PRINT 'ftp_server_password Already Exists.'
END 
GO

IF COL_LENGTH('connection_string', 'ftp_remote_file_path') IS NULL
BEGIN
    ALTER TABLE connection_string ADD ftp_remote_file_path VARCHAR(300) NULL
END
ELSE
BEGIN
    PRINT 'ftp_remote_file_path Already Exists.'
END 
GO

IF COL_LENGTH('connection_string', 'ftp_local_file_path') IS NULL
BEGIN
    ALTER TABLE connection_string ADD ftp_local_file_path VARCHAR(300) NULL
END
ELSE
BEGIN
    PRINT 'ftp_local_file_path Already Exists.'
END 
GO
--change datatype for report server password as varbinary
IF COL_LENGTH('connection_string', 'report_server_password') IS NOT NULL
BEGIN
	ALTER TABLE connection_string DROP COLUMN report_server_password
	ALTER TABLE connection_string ADD report_server_password VARBINARY(1000) NULL
END
ELSE
BEGIN
    PRINT 'report_server_password does not exists.'
END 
