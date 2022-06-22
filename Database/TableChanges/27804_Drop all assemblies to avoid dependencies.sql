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
		WHERE a.name NOT in ('tSQLtCLR')
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

IF EXISTS(SELECT 1 FROM sys.assemblies a WHERE [name] LIKE 'FARRMSGenericCLR')
	DROP ASSEMBLY [FARRMSGenericCLR]
		
IF EXISTS(SELECT 1 FROM sys.assemblies a WHERE [name] LIKE 'FARRMSWebServices')
	DROP ASSEMBLY [FARRMSWebServices]

IF EXISTS(SELECT 1 FROM sys.assemblies a WHERE [name] LIKE 'FAARMSFileTransferCLR')
	DROP ASSEMBLY [FAARMSFileTransferCLR]

IF EXISTS(SELECT 1 FROM sys.assemblies a WHERE [name] LIKE 'FARRMSExportCLR')
	DROP ASSEMBLY [FARRMSExportCLR]

IF EXISTS(SELECT 1 FROM sys.assemblies a WHERE [name] LIKE 'FARRMSImportCLR')
	DROP ASSEMBLY [FARRMSImportCLR]

IF EXISTS(SELECT 1 FROM sys.assemblies a WHERE [name] LIKE 'FARRMSExcelServerCLR')
	DROP ASSEMBLY [FARRMSExcelServerCLR]

IF EXISTS(SELECT 1 FROM sys.assemblies a WHERE [name] LIKE 'FAARMSFileTransferService')
	DROP ASSEMBLY [FAARMSFileTransferService]

IF EXISTS(SELECT 1 FROM sys.assemblies a WHERE [name] LIKE 'FARRMSUtilities')
	DROP ASSEMBLY [FARRMSUtilities]


IF EXISTS(SELECT 1 FROM sys.assemblies a WHERE [name] LIKE 'Jint')
	DROP ASSEMBLY [Jint]

IF EXISTS(SELECT 1 FROM sys.assemblies a WHERE [name] LIKE 'Ionic.Zip')
	DROP ASSEMBLY [Ionic.Zip]

IF EXISTS(SELECT 1 FROM sys.assemblies a WHERE [name] LIKE 'MailKit')
	DROP ASSEMBLY [MailKit]

IF EXISTS(SELECT 1 FROM sys.assemblies a WHERE [name] LIKE 'MimeKit')
	DROP ASSEMBLY [MimeKit]

IF EXISTS(SELECT 1 FROM sys.assemblies a WHERE [name] LIKE 'Renci.SshNet')
	DROP ASSEMBLY [Renci.SshNet]

IF EXISTS(SELECT 1 FROM sys.assemblies a WHERE [name] LIKE 'Spire.Common')
	DROP ASSEMBLY [Spire.Common]

IF EXISTS(SELECT 1 FROM sys.assemblies a WHERE [name] LIKE 'Spire.XLS')
	DROP ASSEMBLY [Spire.XLS]

IF EXISTS(SELECT 1 FROM sys.assemblies a WHERE [name] LIKE 'Spire.Pdf')
	DROP ASSEMBLY [Spire.Pdf]

IF EXISTS(SELECT 1 FROM sys.assemblies a WHERE [name] LIKE 'System.Web')
	DROP ASSEMBLY [System.Web]

IF EXISTS(SELECT 1 FROM sys.assemblies a WHERE [name] LIKE 'WordDocumentGenerator.Library')
	DROP ASSEMBLY [WordDocumentGenerator.Library]

IF EXISTS(SELECT 1 FROM sys.assemblies a WHERE [name] LIKE 'DocumentFormat.OpenXml')
	DROP ASSEMBLY [DocumentFormat.OpenXml]

IF EXISTS(SELECT 1 FROM sys.assemblies a WHERE [name] LIKE 'WindowsBase')
	DROP ASSEMBLY [WindowsBase]

IF EXISTS(SELECT 1 FROM sys.assemblies a WHERE [name] LIKE 'Accessibility')
	DROP ASSEMBLY [Accessibility]

IF EXISTS(SELECT 1 FROM sys.assemblies a WHERE [name] LIKE 'BouncyCastle.Crypto')
	DROP ASSEMBLY [BouncyCastle.Crypto]

IF EXISTS(SELECT 1 FROM sys.assemblies a WHERE [name] LIKE 'Spire.License')
	DROP ASSEMBLY [Spire.License]

IF EXISTS(SELECT 1 FROM sys.assemblies a WHERE [name] LIKE 'System.Xaml')
	DROP ASSEMBLY [System.Xaml]

IF EXISTS(SELECT 1 FROM sys.assemblies a WHERE [name] LIKE 'Newtonsoft.Json')
	DROP ASSEMBLY [Newtonsoft.Json]

IF EXISTS(SELECT 1 FROM sys.assemblies a WHERE [name] LIKE 'MathNet.Numerics')
	DROP ASSEMBLY [MathNet.Numerics]

IF EXISTS(SELECT 1 FROM sys.assemblies a WHERE [name] LIKE 'System.Runtime.Serialization')
	DROP ASSEMBLY [System.Runtime.Serialization]

IF EXISTS(SELECT 1 FROM sys.assemblies a WHERE [name] LIKE 'SMDiagnostics')
	DROP ASSEMBLY [SMDiagnostics]
