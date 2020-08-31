--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20006201)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20006201, 'Add/Save', '', 20006200, '', NULL, NULL, 0)
	PRINT ' Inserted 20006201 - Add/Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20006201 - Add/Save already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20006202)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20006202, 'Delete', '', 20006200, '', NULL, NULL, 0)
	PRINT ' Inserted 20006202 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20006202 - Delete already EXISTS.'
END

GO