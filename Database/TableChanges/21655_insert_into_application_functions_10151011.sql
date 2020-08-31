--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10151011)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10151011, 'Copy Price', 'Copy Price', 10151000, '', NULL, NULL, 0)
	PRINT ' Inserted 10151011 - Copy Price.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10151011 - Copy Price already EXISTS.'
END