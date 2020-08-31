--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20002501)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20002501, 'Add/Save', 'Add/Save', 20002500, '', NULL, NULL, 0)
	PRINT ' Inserted 20002501 - Add/Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20002501 - Add/Save already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20002502)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20002502, 'Delete', 'Delete', 20002500, '', NULL, NULL, 0)
	PRINT ' Inserted 20002502 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20002502 - Delete already EXISTS.'
END
