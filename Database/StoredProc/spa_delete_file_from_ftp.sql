IF OBJECT_ID('spa_delete_file_from_ftp') IS NOT NULL
    DROP PROC spa_delete_file_from_ftp
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spa_delete_file_from_ftp]
(
	@use_import BIT = 1,
    @source_file NVARCHAR(1024),
    @result NVARCHAR(MAX) OUTPUT
)
AS
BEGIN
	DECLARE @ftp_url NVARCHAR(1024), @ftp_username NVARCHAR(1024), @ftp_password NVARCHAR(1024), @enable_ssl NCHAR(1),@use_sftp NCHAR(1)
	
	SELECT @ftp_url = CASE WHEN @use_import = 1 THEN import_ftp_url ELSE export_ftp_url END, 
		   @ftp_username = CASE WHEN @use_import = 1 THEN import_ftp_username ELSE export_ftp_username END, 
		   @ftp_password = CASE WHEN @use_import = 1 THEN dbo.FNADecrypt(import_ftp_password) ELSE dbo.FNADecrypt(export_ftp_password) END,
		   @enable_ssl = CASE WHEN enable_ssl = 1 THEN 'y' ELSE 'n' END,
		   @use_sftp = CASE WHEN use_sftp = 1 THEN 'y' ELSE 'n' END 		     
	FROM connection_string
	
	EXEC spa_ftp_delete_file_using_clr   @ftp_url = @ftp_url, 
										 @ftp_username = @ftp_username, 
										 @ftp_password = @ftp_password, 
										 @source_file = @source_file, 
										 @enable_ssl = @enable_ssl,
										 @use_sftp = @use_sftp, 
										 @output_result = @result OUTPUT
END