--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105200)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10105200, 'Lock As of Date', 'Lock As of Date', NULL, '_setup/lock_as_of_date/lock.as.of.date.php', NULL, NULL, 0)
	PRINT ' Inserted 10105200 - Lock As of Date.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105200 - Lock As of Date already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105210)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10105210, 'Add/Save', 'Add/Save', 10105200, '', NULL, NULL, 0)
	PRINT ' Inserted 10105210 - Add/Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105210 - Add/Save already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105211)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10105211, 'Delete', 'Delete', 10105200, '', NULL, NULL, 0)
	PRINT ' Inserted 10105211 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105211 - Delete already EXISTS.'
END


