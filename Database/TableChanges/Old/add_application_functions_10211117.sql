IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211117)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	VALUES (10211117, 'Delete', 'Delete', '10211115', NULL, NULL, NULL, 0 )
	PRINT 'INSERTED 10211117 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211117 - Delete already EXISTS.'
END