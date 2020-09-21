DECLARE @folder_path VARCHAR(300), @common_dlls_path VARCHAR(500)
SELECT @folder_path = document_path, @common_dlls_path = document_path + '\CLR_deploy\' FROM connection_string
DECLARE @library_path VARCHAR(MAX) = @folder_path + '\CLR_deploy\FARRMSExcelServerCLR\' -- Assembly DLL File path
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

--	Drop Assembly modules
IF OBJECT_ID('spa_synchronize_excel_with_spire') IS NOT NULL
    DROP PROC [spa_synchronize_excel_with_spire]

PRINT 'DROP EXISTING .NET ASSEMBLIES'
IF EXISTS(SELECT 1 FROM sys.assemblies a WHERE [name] LIKE 'FARRMSExcelServerCLR')
	DROP ASSEMBLY [FARRMSExcelServerCLR]
		
IF EXISTS(SELECT 1 FROM sys.assemblies a WHERE [name] LIKE 'Spire.Common')
	DROP ASSEMBLY [Spire.Common]

IF EXISTS(SELECT 1 FROM sys.assemblies a WHERE [name] LIKE 'System.Web')
	DROP ASSEMBLY [System.Web]

IF NOT EXISTS(SELECT 1 FROM   sys.assemblies a WHERE  [name] LIKE 'Accessibility')
BEGIN
	CREATE ASSEMBLY [Accessibility]
	FROM @library_path + 'Accessibility.dll'
	WITH PERMISSION_SET = UNSAFE	
END
ELSE
BEGIN
	BEGIN TRY  
		ALTER ASSEMBLY Accessibility FROM @library_path + 'Accessibility.dll' WITH PERMISSION_SET = UNSAFE  
	END TRY  
	BEGIN CATCH  
		--	Suppressing Error, according to MVID, identical to an assembly that is already registered under the name "Accessibility".
		PRINT 'Accessibility is already registered according to MVID.'
	END CATCH
END

IF NOT EXISTS(SELECT 1 FROM   sys.assemblies a WHERE  [name] LIKE 'System.Xaml')
BEGIN
	CREATE ASSEMBLY [System.Xaml]
	FROM @library_path + 'System.Xaml.dll'
	WITH PERMISSION_SET = UNSAFE	
END
ELSE
BEGIN
	BEGIN TRY  
		ALTER ASSEMBLY [System.Xaml] FROM @library_path + 'System.Xaml.dll' WITH PERMISSION_SET = UNSAFE  
	END TRY  
	BEGIN CATCH  
		--	Suppressing Error, according to MVID, identical to an assembly that is already registered under the name "System.Xaml".
		PRINT 'System.Xaml is already registered according to MVID.'
	END CATCH
END

IF NOT EXISTS(SELECT 1 FROM   sys.assemblies a WHERE  [name] LIKE 'WindowsBase')
BEGIN
	CREATE ASSEMBLY [WindowsBase]
	FROM @common_dlls_path + 'WindowsBase.dll'
	WITH PERMISSION_SET = UNSAFE	
END
ELSE
BEGIN
	BEGIN TRY  
		ALTER ASSEMBLY WindowsBase FROM @common_dlls_path + 'WindowsBase.dll' WITH PERMISSION_SET = UNSAFE  
	END TRY  
	BEGIN CATCH  
		--	Suppressing Error, according to MVID, identical to an assembly that is already registered under the name "WindowsBase".
		PRINT 'WindowsBase is already registered according to MVID.'
	END CATCH
END

---- Spire
DECLARE @frameworkDir VARCHAR(1000)
SELECT @frameworkDir = LEFT(LTRIM(RTRIM(value)), LEN(value) - 1) FROM sys.dm_clr_properties where [name] = 'directory'

IF NOT EXISTS(SELECT 1 FROM   sys.assemblies a WHERE  [name] LIKE 'System.Web')
BEGIN
	CREATE ASSEMBLY [System.Web]
	FROM @frameworkDir + 'System.Web.dll'
	WITH PERMISSION_SET = UNSAFE	
END


IF NOT EXISTS(SELECT 1 FROM   sys.assemblies a WHERE  [name] LIKE 'Spire.Common')
BEGIN
	CREATE ASSEMBLY [Spire.Common]
	FROM @library_path + 'Spire.Common.dll'
	WITH PERMISSION_SET = UNSAFE	
END

IF NOT EXISTS(SELECT 1 FROM   sys.assemblies a WHERE  [name] LIKE 'Spire.License')
BEGIN
	CREATE ASSEMBLY [Spire.License]
	FROM @library_path + 'Spire.License.dll'
	WITH PERMISSION_SET = UNSAFE	
END

IF NOT EXISTS(SELECT 1 FROM   sys.assemblies a WHERE  [name] LIKE 'Spire.Pdf')
BEGIN
	CREATE ASSEMBLY [Spire.Pdf]
	FROM @library_path + 'Spire.Pdf.dll'
	WITH PERMISSION_SET = UNSAFE	
END

IF NOT EXISTS(SELECT 1 FROM   sys.assemblies a WHERE  [name] LIKE 'Spire.XLS')
BEGIN
	CREATE ASSEMBLY [Spire.XLS]
	FROM @library_path + 'Spire.XLS.dll'
	WITH PERMISSION_SET = UNSAFE	
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

IF NOT EXISTS(SELECT 1 FROM sys.assemblies a WHERE [name] LIKE 'FARRMSExcelServerCLR')
BEGIN
	CREATE ASSEMBLY FARRMSExcelServerCLR
	FROM @library_path + 'FARRMSExcelServerCLR.dll'
	WITH PERMISSION_SET = UNSAFE	
END

/**   
    Synchronize excel add-in report / data import / document generation
    Parameters
    @excelSheetId	: Published excel sheet id
	@synchronize	: Synchronize y/n
	@imageSnapshot	: Generate image snapshot y/n
	@userName		: user name
	@settlementCalc : run settlement calc y/n
	@exportFormat	: export format eg. PNG, PDF, HTML, EXCEL
	@processId		: Unique process id
	@outputResult	: output result
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spa_synchronize_excel_with_spire]
(
	@excelSheetId		NVARCHAR(255),
	@synchronize		NVARCHAR(1),
	@imageSnapshot		NVARCHAR(1),
	@userName			NVARCHAR(255),
	@settlementCalc		NVARCHAR(1),
	@exportFormat		NVARCHAR(10),
	@processId			NVARCHAR(255),
	@outputResult		NVARCHAR(MAX) output
)
AS
	EXTERNAL NAME FARRMSExcelServerCLR.[FARRMSExcelServerCLR.StoredProcedure].SynchronizeExcelWithSpire
GO