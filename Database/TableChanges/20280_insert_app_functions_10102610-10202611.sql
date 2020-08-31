IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10202610)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10202610, 'Add/Save', 'Add/Save', 10202600, NULL, NULL, NULL, 0)
	PRINT ' Inserted 10202610 -  Add/Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10202610 - Add/Save already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10202611)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10202611, 'Delete', 'Delete', 10202600, NULL, NULL, NULL, 0)
	PRINT ' Inserted 10202611 -  Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10202611 - Delete already EXISTS.'
END