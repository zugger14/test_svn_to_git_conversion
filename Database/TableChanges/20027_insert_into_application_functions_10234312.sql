IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10234312)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10234312, 'Add', 'Create Hedge Group', 10234300, '', NULL, NULL, 1)
	PRINT ' Inserted 10234312 - Add.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10234312 - Add already EXISTS.'
END