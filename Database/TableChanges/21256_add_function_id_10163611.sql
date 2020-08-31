IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10163611)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10163611, 'Flow Match Filter UI', 'Filter form of flow match', 10163600, '', NULL, NULL, 0)
	PRINT ' Inserted 10163611 - Flow Match Filter UI.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10163611 - Flow Match Filter UI already EXISTS.'
END

