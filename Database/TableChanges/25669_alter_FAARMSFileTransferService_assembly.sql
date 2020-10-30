DECLARE @folder_path VARCHAR(300)
SELECT @folder_path = document_path FROM connection_string
DECLARE @library_path VARCHAR(MAX) = @folder_path + '\CLR_deploy\FAARMSFileTransferCLR\' -- Assembly DLL File path

IF NOT EXISTS(SELECT 1 FROM   sys.assemblies a WHERE  [name] LIKE 'FAARMSFileTransferService')
BEGIN
	CREATE ASSEMBLY [FAARMSFileTransferService]
	FROM @library_path + 'FAARMSFileTransferService.dll'
	WITH PERMISSION_SET = UNSAFE	
END
ELSE
BEGIN
	BEGIN TRY  
		ALTER ASSEMBLY FAARMSFileTransferService FROM @library_path + 'FAARMSFileTransferService.dll' WITH PERMISSION_SET = UNSAFE  
	END TRY  
	BEGIN CATCH  
		--	Suppressing Error, according to MVID, identical to an assembly that is already registered under the name "FAARMSFileTransferService".
		PRINT 'FAARMSFileTransferService is already registered according to MVID.'
	END CATCH
END
