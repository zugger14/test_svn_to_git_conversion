IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10202400)
	BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	VALUES (10202400, 'Spa HTML Template', 'Spa HTML Template', 10200000, NULL, NULL, '', 0)
	PRINT 'INSERTED 10202400 - Spa HTML Template.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10202400 - Spa HTML Template already EXISTS.'
END