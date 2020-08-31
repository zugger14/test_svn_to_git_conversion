IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10202614)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10202614, 'Batch', 'Batch', 10202600, NULL, NULL, NULL, 0)
	PRINT ' Inserted 10202614 -  Batch.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10202614 - Batch already EXISTS.'
END