IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10234310)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10234310, 'Run', 'Select Deals Group', 10234300, '', NULL, NULL, 0)
	PRINT ' Inserted 10234310 - Run.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10234310 - Run already EXISTS.'
END