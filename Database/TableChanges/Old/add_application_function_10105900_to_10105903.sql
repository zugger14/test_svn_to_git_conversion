IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105900)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10105900, 'Approved Counterparty', 'Approved Counterparty', 10105800, '', '', '', 0)
	PRINT ' Inserted 10105900 - Approved Counterparty.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105900 - Approved Counterparty already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105901)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10105901, 'Add/Save Counterparty', 'Add/Save Counterparty', 10105900, '', '', '', 0)
	PRINT ' Inserted 10105901 - Add/Save Counterparty.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105901 - Add/Save Counterparty already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105902)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10105902, 'Delete', 'Delete', 10105900, '', '', '', 0)
	PRINT ' Inserted 10105902 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105902 - Delete already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105903)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10105903, 'Add/Save Product', 'Add/Save Product', 10105900, '', '', '', 0)
	PRINT ' Inserted 10105903 - Add/Save Product.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105903 - Add/Save Product already EXISTS.'
END