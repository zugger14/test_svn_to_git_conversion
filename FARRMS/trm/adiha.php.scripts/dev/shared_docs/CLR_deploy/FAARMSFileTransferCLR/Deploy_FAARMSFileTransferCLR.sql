DECLARE @folder_path VARCHAR(300)
SELECT @folder_path = document_path FROM connection_string
DECLARE @library_path VARCHAR(MAX) = @folder_path + '\CLR_deploy\FAARMSFileTransferCLR\' -- Assembly DLL File path

DECLARE @command NVARCHAR(1024) = N'ALTER AUTHORIZATION ON DATABASE::[<<DatabaseName>>] TO [<<LoginName>>]' 
DECLARE @db_name NVARCHAR(250) = DB_NAME()
/*
Logic to change db owner is:
a. If current db owner is SQL login & has sysadmin privilege, set it as it is.
b. Otherwise, get [sa] account and set it as db owner. There should be no impact even if this account is disabled. 
*/
SELECT @command = REPLACE(
					REPLACE(@command,  '<<DatabaseName>>', @db_name)
						, '<<LoginName>>', ISNULL(rs_db_owner.name, sl.name))
	FROM sys.sql_logins sl
	LEFT JOIN (
		--get current db user name only if it has sysadmin role
		SELECT rs_owner.name
		FROM sys.databases d
		CROSS APPLY (SELECT suser_sname(d.owner_sid) name) rs_owner
		INNER JOIN sys.server_principals sp ON rs_owner.name = sp.name
		WHERE d.name = DB_NAME()
			AND IS_SRVROLEMEMBER('sysadmin', rs_owner.name) = 1
			AND sp.type_desc = 'SQL_LOGIN'
		) rs_db_owner ON  1 = 1	--Using CROSS JOIN returns empty set if the second set is also empty. So LEFT JOIN with always true condition is used.
	WHERE sl.sid = 0x01;		--get sa user, which may be renamed to other name. So it is safe to use sid instead of hardcoding sa

EXEC (@command)


--	Drop Assembly modules related to FTP
IF OBJECT_ID('spa_upload_file_to_ftp_using_clr') IS NOT NULL
    DROP PROC spa_upload_file_to_ftp_using_clr

IF OBJECT_ID('spa_download_file_from_ftp_using_clr') IS NOT NULL
    DROP PROC spa_download_file_from_ftp_using_clr

IF OBJECT_ID('spa_list_ftp_contents_using_clr') IS NOT NULL
    DROP PROC spa_list_ftp_contents_using_clr

IF OBJECT_ID('spa_move_ftp_file_to_folder_using_clr') IS NOT NULL
    DROP PROC spa_move_ftp_file_to_folder_using_clr

IF OBJECT_ID('spa_ftp_delete_file_using_clr') IS NOT NULL
    DROP PROC spa_ftp_delete_file_using_clr

IF OBJECT_ID('spa_test_file_transfer_endpoint_connection') IS NOT NULL
    DROP PROC [spa_test_file_transfer_endpoint_connection]


IF NOT EXISTS(SELECT 1 FROM   sys.assemblies a WHERE  [name] LIKE 'FARRMSUtilities')
BEGIN
	CREATE ASSEMBLY [FARRMSUtilities]
	FROM @library_path + 'FARRMSUtilities.dll'
	WITH PERMISSION_SET = UNSAFE	
END
ELSE
BEGIN
	BEGIN TRY  
		ALTER ASSEMBLY FARRMSUtilities FROM @library_path + 'FARRMSUtilities.dll' WITH PERMISSION_SET = UNSAFE  
	END TRY  
	BEGIN CATCH  
		--	Suppressing Error, according to MVID, identical to an assembly that is already registered under the name "FARRMSUtilities".
		PRINT 'FARRMSUtilities is already registered according to MVID.'
	END CATCH
END

IF EXISTS(SELECT 1 FROM sys.assemblies a WHERE [name] LIKE 'FAARMSFileTransferCLR')
	DROP ASSEMBLY [FAARMSFileTransferCLR]


IF NOT EXISTS(SELECT 1 FROM sys.assemblies a WHERE [name] LIKE 'FAARMSFileTransferCLR')
BEGIN
	CREATE ASSEMBLY FAARMSFileTransferCLR
	FROM @library_path + 'FAARMSFileTransferCLR.dll'
	WITH PERMISSION_SET = UNSAFE	
END



--FTP Upload
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spa_upload_file_to_ftp_using_clr]
(
    @file_transfer_endpoint_id INT,
	@target_remote_directory NVARCHAR(1024),
    @source_file NVARCHAR(1024),
    @output_result NVARCHAR(MAX) OUTPUT
)
AS
EXTERNAL NAME FAARMSFileTransferCLR.[FAARMSFileTransferCLR.StoredProcedure].UploadToFtp
GO
-- FTP Download
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spa_download_file_from_ftp_using_clr]
(
    @file_transfer_endpoint_id INT,
	@target_remote_directory NVARCHAR(1024),
    @source_file NVARCHAR(1024),
    @destination NVARCHAR(1024),
	@extension NVARCHAR(10),
    @output_result NVARCHAR(MAX) OUTPUT
)
AS
EXTERNAL NAME FAARMSFileTransferCLR.[FAARMSFileTransferCLR.StoredProcedure].DownloadFromFtp
GO
-- List Ftp Contents
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spa_list_ftp_contents_using_clr]
(
    @file_transfer_endpoint_id INT,
	@target_remote_directory NVARCHAR(1024),
    @output_result NVARCHAR(MAX) OUTPUT
)
AS
EXTERNAL NAME FAARMSFileTransferCLR.[FAARMSFileTransferCLR.StoredProcedure].ListFtpContents
GO

-- Move ftp file to folder

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spa_move_ftp_file_to_folder_using_clr]
(
    @file_transfer_endpoint_id INT,
	@remoteWorkingDirectory NVARCHAR(1024),
	@targetRemoteDirectory NVARCHAR(1024),
	@source_file NVARCHAR(1024),    
    @output_result NVARCHAR(MAX) OUTPUT
)
AS
EXTERNAL NAME FAARMSFileTransferCLR.[FAARMSFileTransferCLR.StoredProcedure].FtpMoveFileToFolder
GO

-- Delete File From FTP

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spa_ftp_delete_file_using_clr]
(
    @file_transfer_endpoint_id INT,
    @source_file NVARCHAR(1024),
    @output_result NVARCHAR(MAX) OUTPUT
)
AS
EXTERNAL NAME FAARMSFileTransferCLR.[FAARMSFileTransferCLR.StoredProcedure].FtpDeleteFile
GO

-- Test FTP Connection
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spa_test_file_transfer_endpoint_connection]
(
    @file_transfer_endpoint_id INT,
    @output_result NVARCHAR(MAX) OUTPUT
)
AS
EXTERNAL NAME FAARMSFileTransferCLR.[FAARMSFileTransferCLR.StoredProcedure].TestFileTransferEndpointConnection
GO
