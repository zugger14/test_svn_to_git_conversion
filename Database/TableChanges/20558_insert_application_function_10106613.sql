--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10106613)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10106613, 'Action ', 'Action ', 10106612, '', NULL, NULL, 0)
	PRINT ' Inserted 10106613 - Action .'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10106613 - Action  already EXISTS.'
END