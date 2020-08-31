IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101215)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10101215, 'Sub Book Transfer Property', 'Sub Book Transfer Property', NULL, NULL, '', '', 1)
	PRINT ' Inserted 10101215 - Sub Book Transfer Property.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101215 - Sub Book Transfer Property already EXISTS.'
END
