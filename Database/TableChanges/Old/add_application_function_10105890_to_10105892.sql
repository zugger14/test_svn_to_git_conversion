IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105890)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	VALUES (10105890, 'Product', 'Product', '10105800', NULL, NULL, NULL, 0 )
	PRINT 'INSERTED 10105890 - Product.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105890 - Product already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105891)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	VALUES (10105891, 'Add/Save', 'Add/Save', '10105890', NULL, NULL, NULL, 0 )
	PRINT 'INSERTED 10105891 - Add/Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105891 - Add/Save already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105892)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	VALUES (10105892, 'Delete', 'Delete', '10105890', NULL, NULL, NULL, 0 )
	PRINT 'INSERTED 10105892 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105892 - Delete already EXISTS.'
END