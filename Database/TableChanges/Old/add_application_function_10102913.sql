IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10102913)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10102913, 'Manage Documents - Message', 'Manage Documents - Message', 10102900, 'windowManageDocumentsMessage')
 	PRINT ' Inserted 10102913 - Manage Documents -Message.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10102913 - Manage Documents - Message already EXISTS.'
END
