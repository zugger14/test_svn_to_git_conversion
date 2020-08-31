IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10106200)
	BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required, function_parameter)
	VALUES (10106200, 'Setup Weather Data', 'Setup Weather Data', 10100000, NULL, NULL, '_setup/setup_time_series/setup.time.series.php', 0, 10106200)
	PRINT 'INSERTED 10106100 - Setup Weather Data.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10106200 - Setup Weather Data already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10106210)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	VALUES (10106210, 'Add/Save', 'Add/Save', 10106200, '', NULL, '', 0)
 	PRINT ' Inserted 10106210 - Add/Save'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10106210 - Add/Save already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10106211)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	VALUES (10106211, 'Delete', 'Delete', 10106200, '', NULL, '', 0)
 	PRINT ' Inserted 10106111 - Delete'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10106211 - Delete already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10106215)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	VALUES (10106215, 'Weather Values', 'Weather Values', 10106200, '', NULL, '', 0)
 	PRINT ' Inserted 10106212 - Weather Values.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10106215 - Weather Values already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10106216)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	VALUES (10106216, 'Add/Save', 'Add/Save', 10106215, '', NULL, '', 0)
 	PRINT ' Inserted 10106213 - Add/Save '
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10106216 - Add/Save  already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10106217)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	VALUES (10106217, 'Delete', 'Delete', 10106215, '', NULL, '', 0)
 	PRINT ' Inserted 10106213 - Delete'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10106217 - Delete  already EXISTS.'
END
