DECLARE @folder_path VARCHAR(300), @common_dlls_path VARCHAR(500)
SELECT @folder_path = document_path, @common_dlls_path = document_path + '\CLR_deploy\' FROM connection_string
DECLARE @library_path VARCHAR(MAX) = @folder_path + '\CLR_deploy\FARRMSImportCLR\' -- Assembly DLL File path

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

--	Drop Assembly modules
IF OBJECT_ID('spa_ixp_call_clr_function') IS NOT NULL
    DROP PROC spa_ixp_call_clr_function

IF EXISTS(SELECT 1 FROM sys.assemblies a WHERE [name] LIKE 'FARRMSImportCLR')
	DROP ASSEMBLY FARRMSImportCLR

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

IF NOT EXISTS(SELECT 1 FROM sys.assemblies a WHERE [name] LIKE 'FARRMSImportCLR')
BEGIN
	CREATE ASSEMBLY FARRMSImportCLR
	FROM @library_path + 'FARRMSImportCLR.dll'
	WITH PERMISSION_SET = UNSAFE	
END


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO 
CREATE PROC [dbo].spa_ixp_call_clr_function
(
	@parameter_xml NVARCHAR(MAX),
	@ixp_rule_id INT,
	@process_id NVARCHAR(500)
)
AS

	EXTERNAL NAME FARRMSImportCLR.[FARRMSImportCLR.StoredProcedure].ImportWithCLRRule
GO

