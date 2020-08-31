--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10102912)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10102912, 'Incident', 'Incident', 10102900, '', NULL, NULL, 0)
	PRINT ' Inserted 10102912 - Incident.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10102912 - Incident already EXISTS.'
END