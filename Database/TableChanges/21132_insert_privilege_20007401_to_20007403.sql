--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20007401)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20007401, 'Add/Save', 'Add/Save', 20007400, '', NULL, NULL, 0)
	PRINT ' Inserted 20007401 - Add/Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20007401 - Add/Save already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20007402)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20007402, 'Delete', 'Delete', 20007400, '', NULL, NULL, 0)
	PRINT ' Inserted 20007402 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20007402 - Delete already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20007403)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20007403, 'Run', 'Run', 20007400, '', NULL, NULL, 0)
	PRINT ' Inserted 20007403 - Run.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20007403 - Run already EXISTS.'
END