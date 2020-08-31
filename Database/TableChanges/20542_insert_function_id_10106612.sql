--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10106612)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10106612, 'Workflow Status Report', 'Workflow Status Report', 10106600, '', NULL, NULL, 0)
	PRINT ' Inserted 10106612 - Workflow Status Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10106612 - Workflow Status Report already EXISTS.'
END