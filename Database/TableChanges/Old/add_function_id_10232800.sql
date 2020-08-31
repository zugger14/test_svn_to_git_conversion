IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10232800)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10232800, 'Import Audit Report', 'Import Audit Report', 10230000, 'windowRunFilesImportAuditReport')
 	PRINT ' Inserted 10232800 - Import Audit Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10232800 - Import Audit Report already EXISTS.'
END
