--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105001)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10105001, 'Add/Save', 'Add/Save', 10105000, '', NULL, NULL, 0)
	PRINT ' Inserted 10105001 - Add/Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105001 - Add/Save already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105002)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10105002, 'Delete', 'Delete', 10105000, '', NULL, NULL, 0)
	PRINT ' Inserted 10105002 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105002 - Delete already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105003)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10105003, 'Filter Setup Menu', 'Filter Setup Menu', 10105000, '', NULL, NULL, 0)
	PRINT ' Inserted 10105003 - Filter Setup Menu.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105003 - Filter Setup Menu already EXISTS.'
END
                                        