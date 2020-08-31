IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10122600)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10122600, 'Setup Simple Alert', 'Setup Simple Alert', NULL, '_compliance_management/setup_alerts/setup.alerts.simple.php', '', '', 0)
	PRINT ' Inserted 10122600 - Setup Simple Alert.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10122600 - Setup Simple Alert already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10122610)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10122610, 'Add/Save', 'Add/Save', 10122600, '', '', '', 0)
	PRINT ' Inserted 10122610 - Add/Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10122610 - Add/Save already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10122611)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10122611, 'Delete', 'Delete', 10122600, '', '', '', 0)
	PRINT ' Inserted 10122611 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10122611 - Delete already EXISTS.'
END