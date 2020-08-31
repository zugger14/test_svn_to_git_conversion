IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10164412)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10164412, 'Send Confirmation', 'Send Confirmation', 10164400, '', NULL, NULL, 0)
	PRINT ' Inserted 10164412 - Send Confirmation.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10164412 - Send Confirmation already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10164413)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10164413, 'Send Scheduled Quantity', 'Send Scheduled Quantity', 10164400, '', NULL, NULL, 0)
	PRINT ' Inserted 10164413 - Send Scheduled Quantity.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10164413 - Send Scheduled Quantity already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10164414)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10164414, 'Send Allocated Quantity', 'Send Allocated Quantity', 10164400, '', NULL, NULL, 0)
	PRINT ' Inserted 10164414 - Send Allocated Quantity.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10164414 - Send Allocated Quantity already EXISTS.'
END