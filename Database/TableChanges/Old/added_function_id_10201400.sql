IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201400)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10201400, 'Run Import Audit Report', 'Run Import Audit Report', 10200000, 'windowRunFilesImportAuditReport')
 	PRINT ' Inserted 
 	 - Run Import Audit Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10201400 - Run Import Audit Report already EXISTS.'
END	


