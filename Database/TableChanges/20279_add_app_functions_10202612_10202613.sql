IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10202612)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10202612, 'Download', 'Download', 10202600, NULL, NULL, NULL, 0)
	PRINT ' Inserted 10202612 -  Download.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10202612 - Download already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10202613)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10202613, 'Privilege', 'Privilege', 10202600, NULL, NULL, NULL, 0)
	PRINT ' Inserted 10202613 -  Privilege.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10202613 - Privilege already EXISTS.'
END