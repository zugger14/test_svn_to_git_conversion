--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20007301)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20007301, 'Delete', 'Delete', 20007300, '', NULL, NULL, 0)
	PRINT ' Inserted 20007301 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20007301 - Delete already EXISTS.'
END

