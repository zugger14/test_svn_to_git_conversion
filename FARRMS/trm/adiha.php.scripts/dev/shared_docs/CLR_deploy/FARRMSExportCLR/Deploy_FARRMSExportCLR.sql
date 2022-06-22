DECLARE @folder_path VARCHAR(300), @common_dlls_path VARCHAR(500)
SELECT @folder_path = document_path, @common_dlls_path = document_path + '\CLR_deploy\' FROM connection_string
DECLARE @library_path VARCHAR(MAX) = @folder_path + '\CLR_deploy\FARRMSExportCLR\' -- Assembly DLL File path

DECLARE @db_name NVARCHAR(250) = DB_NAME()
--check database owner is [sa] or not
IF((SELECT owner_sid FROM sys.databases WHERE name =@db_name)!=0x01 )
BEGIN
	DECLARE @command NVARCHAR(1024) = N'ALTER AUTHORIZATION ON DATABASE::[<<DatabaseName>>] TO [<<LoginName>>]' 
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
END

--	Drop Assembly modules related to FTP
IF OBJECT_ID('spa_post_data_to_web_service') IS NOT NULL
    DROP PROC spa_post_data_to_web_service

IF EXISTS(SELECT 1 FROM sys.assemblies a WHERE [name] LIKE 'FARRMSExportCLR')
	DROP ASSEMBLY FARRMSExportCLR

	-- Resolve .net framework dir to pick the dependent assemblies
DECLARE @frameworkDir VARCHAR(1000)
SELECT @frameworkDir = LEFT(LTRIM(RTRIM(value)), LEN(value) - 1) FROM sys.dm_clr_properties where [name] = 'directory'

IF NOT EXISTS(SELECT 1 FROM   sys.assemblies a WHERE  [name] LIKE 'System.Runtime.Serialization')
BEGIN
	CREATE ASSEMBLY [System.Runtime.Serialization]
	FROM @frameworkDir + 'System.Runtime.Serialization.dll'
	WITH PERMISSION_SET = UNSAFE	
END
ELSE
BEGIN
	BEGIN TRY  
		ALTER ASSEMBLY [System.Runtime.Serialization] FROM @frameworkDir + 'System.Runtime.Serialization.dll' WITH PERMISSION_SET = UNSAFE  
	END TRY  
	BEGIN CATCH  
		--	Suppressing Error, according to MVID, identical to an assembly that is already registered under the name "System.Runtime.Serialization".
		PRINT 'System.Runtime.Serialization is already registered according to MVID.'
	END CATCH
END

IF NOT EXISTS(SELECT 1 FROM   sys.assemblies a WHERE  [name] LIKE 'Newtonsoft.Json')
BEGIN
	CREATE ASSEMBLY [Newtonsoft.Json]
	FROM @common_dlls_path + 'Newtonsoft.Json.dll'
	WITH PERMISSION_SET = UNSAFE	
END
ELSE
BEGIN
	BEGIN TRY  
		ALTER ASSEMBLY [Newtonsoft.Json] FROM @common_dlls_path + 'Newtonsoft.Json.dll' WITH PERMISSION_SET = UNSAFE  
	END TRY  
	BEGIN CATCH  
		--	Suppressing Error, according to MVID, identical to an assembly that is already registered under the name "WindowsBase".
		PRINT 'Newtonsoft.Json is already registered according to MVID.'
	END CATCH
END

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

IF NOT EXISTS(SELECT 1 FROM sys.assemblies a WHERE [name] LIKE 'FARRMSExportCLR')
BEGIN
	CREATE ASSEMBLY FARRMSExportCLR
	FROM @library_path + 'FARRMSExportCLR.dll'
	WITH PERMISSION_SET = UNSAFE	
END




/*
 * Description : Post data to webservice
 * Param Description
		@export_web_service_id      : Web service id from table export_web_service contianing the details of web service information (e.g. url, authentication scheme)
		@table_name_or_query		: Table name holding the data or Query to prepare data to export
		@export_file_full_path      : Exported file full path e.g. exported csv, xml
		@process_id			   		: Process id
		@outmsg			        	: Return Success or error message in case of Failed.
		E.g.				    	: EXEC spa_post_data_to_web_service 1, '', 'spa_convert_to_afas_json','BJ7H894GF6G6H7H' @outmsg;

 */ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO 
CREATE PROCEDURE [dbo].[spa_post_data_to_web_service]
	@export_web_service_id	    INT,
	@table_name_or_query		NVARCHAR(MAX),
	@export_file_full_path		NVARCHAR(1024),
	@process_id					NVARCHAR(1024),
	@outmsg					    NVARCHAR(MAX) OUTPUT
AS
	EXTERNAL NAME FARRMSExportCLR.[FARRMSExportCLR.StoredProcedure].PostDataToWebService
GO