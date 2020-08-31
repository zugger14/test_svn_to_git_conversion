IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131024)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10131024, 'Transfer', 'Transfer', 10131000, '', NULL, NULL, 1)
	PRINT ' Inserted 10131024 - Transfer.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131024 - Transfer already EXISTS.'
END