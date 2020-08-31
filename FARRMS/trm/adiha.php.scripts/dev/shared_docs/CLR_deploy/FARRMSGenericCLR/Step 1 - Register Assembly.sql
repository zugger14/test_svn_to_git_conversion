-- After Executing this script please run - Step 2- Create Assembly Function-StoredProcedures 
-- Check DB_OWNER Conflicts if sa doesnt exists
-- Last Modified : 2019-05-03 02:18:55.580
--select getdate()

DECLARE @drop_existing_system_assembly BIT = 1	--	If set to true it will drop existing .net assemblies that were used
DECLARE @folder_path VARCHAR(300)
SELECT @folder_path = document_path FROM connection_string
DECLARE @library_path VARCHAR(MAX) = @folder_path + '\CLR_deploy\FARRMSGenericCLR\' -- Assembly DLL File path

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

-- Drop Assembly Modules
PRINT '1. Drop Assembly Modules'

DECLARE @object_name VARCHAR(255),@object_type CHAR(1)
DECLARE asembly_cursor CURSOR FOR
SELECT o.name,
       CASE WHEN o.type_desc = 'CLR_STORED_PROCEDURE' THEN 'P' ELSE 'F' END
FROM   sys.assembly_modules am
       INNER JOIN sys.assemblies a
            ON  a.assembly_id = am.assembly_id
       INNER JOIN sys.objects o
            ON  o.object_id = am.object_id
		WHERE a.name in ('FARRMSGenericCLR')
ORDER BY
       a.name,
       am.assembly_class
OPEN asembly_cursor
FETCH NEXT FROM asembly_cursor INTO @object_name, @object_type
WHILE @@FETCH_STATUS = 0
BEGIN
	IF @object_type = 'p'
	BEGIN
		--PRINT 'DROP Asembly Stored Procedure ' + @object_name
		EXEC ('DROP PROC ' + @object_name)
	END
	ELSE IF @object_type = 'F'
	BEGIN
		--PRINT 'DROP Assembly Function ' + @object_name
		EXEC('DROP FUNCTION ' + @object_name)
	END
	FETCH NEXT FROM asembly_cursor INTO @object_name, @object_type	
END

CLOSE asembly_cursor 
DEALLOCATE asembly_cursor


-- Drop existing assemblies
IF @drop_existing_system_assembly = 1
BEGIN
	PRINT 'DROP EXISTING .NET ASSEMBLIES'
	--Remove FARRMS_CLR (old assembly) if exists as it is not required. If not removed, removin Jint will fail due to dependency.
	IF EXISTS(SELECT 1 FROM sys.assemblies a WHERE [name] LIKE 'FARRMS_CLR')
		DROP ASSEMBLY [FARRMS_CLR]
		
	IF EXISTS(SELECT 1 FROM sys.assemblies a WHERE [name] LIKE 'FARRMSGenericCLR')
		DROP ASSEMBLY FARRMSGenericCLR

	IF EXISTS(SELECT 1 FROM sys.assemblies a WHERE [name] LIKE 'FARRMSWebServices')
		DROP ASSEMBLY FARRMSWebServices
	
	IF EXISTS(SELECT 1 FROM sys.assemblies a WHERE [name] LIKE 'WordDocumentGenerator.Library')
		DROP ASSEMBLY [WordDocumentGenerator.Library]
	
	IF EXISTS(SELECT 1 FROM sys.assemblies a WHERE [name] LIKE 'DocumentFormat.OpenXml')
		DROP ASSEMBLY [DocumentFormat.OpenXml]

	IF EXISTS(SELECT 1 FROM sys.assemblies a WHERE [name] LIKE 'Jint')
		DROP ASSEMBLY [Jint]
	
	/* MAIL RELATED DLL DROP (START) */	
	IF EXISTS(SELECT 1 FROM sys.assemblies a WHERE [name] LIKE 'MailKit')
		DROP ASSEMBLY [MailKit]

	IF EXISTS(SELECT 1 FROM sys.assemblies a WHERE [name] LIKE 'MimeKit')
		DROP ASSEMBLY [MimeKit]

	IF EXISTS(SELECT 1 FROM sys.assemblies a WHERE [name] LIKE 'BouncyCastle.Crypto')
		DROP ASSEMBLY [BouncyCastle.Crypto]
	/* MAIL RELATED DLL DROP (END) */

END

-- Check if CLR configuration is enabled or not if not enable it 
IF EXISTS (SELECT * FROM sys.configurations WHERE name = 'clr enabled' AND [value] = 0)
BEGIN
	EXEC sp_CONFIGURE 'show advanced options' , '1'
	RECONFIGURE;
	EXEC sp_CONFIGURE 'clr enabled' , '1'
	RECONFIGURE
	PRINT '2. CLR configuration enabled'
END
ELSE
	PRINT '2. CLR configuration enabled already.'

-- Database must be TRUSTWORTHY 

IF EXISTS(SELECT is_trustworthy_on FROM sys.databases  WHERE name = @db_name AND is_trustworthy_on = 0)
BEGIN
	EXEC ('USE MASTER; ALTER DATABASE ' + @db_name + ' SET trustworthy ON; USE ' + @db_name )
	PRINT '3. Database TRUSTWORTHY option set to TRUE'
END
ELSE
	PRINT + '3. ' +  @db_name +  ' is TRUSTWORTHY already.'

IF EXISTS(SELECT 1 FROM sys.assemblies a WHERE [name] LIKE 'FARRMSGenericCLR')
	DROP ASSEMBLY FARRMSGenericCLR

IF NOT EXISTS(SELECT 1 FROM   sys.assemblies a WHERE  [name] LIKE 'WordDocumentGenerator.Library')
BEGIN
	CREATE ASSEMBLY [WordDocumentGenerator.Library]
	FROM @library_path + 'WordDocumentGenerator.Library.dll'
	WITH PERMISSION_SET = UNSAFE	
END

IF NOT EXISTS(SELECT 1 FROM   sys.assemblies a WHERE  [name] LIKE 'DocumentFormat.OpenXml')
BEGIN
	CREATE ASSEMBLY [DocumentFormat.OpenXml]
	FROM @library_path + 'DocumentFormat.OpenXml.dll'
	WITH PERMISSION_SET = UNSAFE	
END    



IF NOT EXISTS(SELECT 1 FROM   sys.assemblies a WHERE  [name] LIKE 'System.Xaml')
BEGIN
	CREATE ASSEMBLY [System.Xaml]
	FROM @library_path + 'System.Xaml.dll'
	WITH PERMISSION_SET = UNSAFE	
END 

IF NOT EXISTS(SELECT 1 FROM   sys.assemblies a WHERE  [name] LIKE 'Jint')
BEGIN
	CREATE ASSEMBLY [Jint]
	FROM @library_path + 'Jint.dll'
	WITH PERMISSION_SET = UNSAFE	
END

/* ADDED DLL FOR MAIL SYSTEM (START) */
IF NOT EXISTS(SELECT 1 FROM   sys.assemblies a WHERE  [name] LIKE 'BouncyCastle.Crypto')
BEGIN
	CREATE ASSEMBLY [BouncyCastle.Crypto]
	FROM @library_path + 'BouncyCastle.Crypto.dll'
	WITH PERMISSION_SET = UNSAFE	
END

IF NOT EXISTS(SELECT 1 FROM   sys.assemblies a WHERE  [name] LIKE 'MailKit')
BEGIN
	CREATE ASSEMBLY [MailKit]
	FROM @library_path + 'MailKit.dll'
	WITH PERMISSION_SET = UNSAFE	
END

IF NOT EXISTS(SELECT 1 FROM   sys.assemblies a WHERE  [name] LIKE 'MimeKit')
BEGIN
	CREATE ASSEMBLY [MimeKit]
	FROM @library_path + 'MimeKit.dll'
	WITH PERMISSION_SET = UNSAFE	
END

------------------------------------------
/* ADDED DLL FOR MAIL SYSTEM (END) */



-- FARRMSWebServices Class Library
IF NOT EXISTS(SELECT 1 FROM   sys.assemblies a WHERE  [name] LIKE 'FARRMSWebServices')
BEGIN
	CREATE ASSEMBLY [FARRMSWebServices]
	FROM @library_path + 'FARRMSWebServices.dll'
	WITH PERMISSION_SET = UNSAFE	
END

IF NOT EXISTS(SELECT 1 FROM sys.assemblies a WHERE [name] LIKE 'FARRMSGenericCLR')
BEGIN
	CREATE ASSEMBLY FARRMSGenericCLR
	FROM @library_path + 'FARRMSGenericCLR.dll'
	WITH PERMISSION_SET = UNSAFE	
END
ELSE
BEGIN
	ALTER ASSEMBLY FARRMSGenericCLR
	FROM @library_path + 'FARRMSGenericCLR.dll'
	WITH PERMISSION_SET = UNSAFE			
END