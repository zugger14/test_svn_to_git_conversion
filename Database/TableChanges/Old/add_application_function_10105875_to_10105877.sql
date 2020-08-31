IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105875)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	VALUES (10105875, 'Certificate', 'Certificate', '10105800', NULL, NULL, NULL, 0 )
	PRINT 'INSERTED 10105875 - Certificate.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105875 - Certificate already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105876)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	VALUES (10105876, 'Add/Save', 'Add/Save', '10105875', NULL, NULL, NULL, 0 )
	PRINT 'INSERTED 10105876 - Add/Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105876 - Add/Save already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105877)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	VALUES (10105877, 'Delete', 'Delete', '10105875', NULL, NULL, NULL, 0 )
	PRINT 'INSERTED 10105877 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105877 - Delete already EXISTS.'
END