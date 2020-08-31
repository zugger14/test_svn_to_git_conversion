IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101020)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	VALUES (10101020, 'Manage Privilege', 'Privilege', '10101000', NULL, NULL, NULL, 0)
	PRINT 'INSERTED 10101020 -Privilege.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101020 - Privilege already EXISTS.'
	UPDATE application_functions SET function_name = 'Manage Privilege'
	WHERE function_id = 10101020	
	PRINT 'Application FunctionID 10101020 - Updated Successfully.'
END

GO