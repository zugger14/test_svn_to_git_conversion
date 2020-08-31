IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105861)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	VALUES (10105861, 'Add/Save', 'Add/Save', '10105860', NULL, NULL, NULL, 0 )
	PRINT 'INSERTED 10105861 - Add/Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105861 - Add/Save already EXISTS.'
END