--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20010601)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20010601, 'Add/Save', 'Add/Save', 20010600, '', NULL, NULL, 0)
	PRINT ' Inserted 20010601 - Add/Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20010601 - Add/Save already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20010602)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20010602, 'Delete', 'Delete', 20010600, '', NULL, NULL, 0)
	PRINT ' Inserted 20010602 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20010602 - Delete already EXISTS.'
END