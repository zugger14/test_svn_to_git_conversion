IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10166100)
	BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required, function_parameter)
	VALUES (10166100, 'Setup Fuel Loss Group', 'Setup Fuel Loss Group', 10160000, NULL, NULL, '_setup/setup_time_series/setup.time.series.php', 0, 10166100)
	PRINT 'INSERTED 10166100 - Setup Fuel Loss Group.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10166100 - Setup Fuel Loss Group already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10166110)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	VALUES (10166110, 'Add', 'Add', 10166100, '', NULL, '', 0)
 	PRINT ' Inserted 10166110 - Add.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10166110 - Add already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10166111)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	VALUES (10166111, 'Delete', 'Delete', 10166100, '', NULL, '', 0)
 	PRINT ' Inserted 10166111 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10166111 - Delete already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10166112)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	VALUES (10166112, 'Values Add/Save/Delete', 'Values Add/Save/Delete', 10166100, '', NULL, '', 0)
 	PRINT ' Inserted 10166112 - Values Add/Save/Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10166112 - Values Add/Save/Delete already EXISTS.'
END

