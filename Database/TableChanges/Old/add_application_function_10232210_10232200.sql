IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10232210)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10232210, 'Manage Documents IU', 'Manage Documents IU', 10232200, 'windowManageDocumentsIU')
 	PRINT ' Inserted 10232210 - Manage Documents IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10232210 - Manage Documents IU already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10232200)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10232200, 'Manage Documents', 'Manage Documents', 13100000, 'windowManageDocuments')
 	PRINT ' Inserted 10232200 - Manage Documents.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10232200 - Manage Documents already EXISTS.'
END


