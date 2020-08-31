--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20001801)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20001801, 'Add/Save', 'Add/Save', 20001800, '', NULL, NULL, 0)
	PRINT ' Inserted 20001801 - Add/Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20001801 - Add/Save already EXISTS.'
END
