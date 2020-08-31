IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10102410)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	VALUES (10102410, 'Formula Builder Delete', 'Formula Builder Delete', 10221000, NULL, NULL, NULL, 0 )
	PRINT 'INSERTED 10102410 - Formula Builder Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10102410 - Formula Builder Delete already EXISTS.'
END