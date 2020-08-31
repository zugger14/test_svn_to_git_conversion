IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10221026)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	VALUES (10221026, 'Update Invoice Status', 'Update Invoice Status', 10221000, NULL, NULL, NULL, 0 )
	PRINT 'INSERTED 10221026 - Update Invoice Status.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10221026 - Update Invoice Status already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10221027)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	VALUES (10221027, 'View Audit', 'View Audit', 10221000, NULL, NULL, NULL, 0 )
	PRINT 'INSERTED 10221027 - View Audit.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10221027 - View Audit already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10221028)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	VALUES (10221028, 'Invoice Split', 'Invoice Split', 10221000, NULL, NULL, NULL, 0 )
	PRINT 'INSERTED 10221028 - Invoice Split.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10221028 - Invoice Split already EXISTS.'
END