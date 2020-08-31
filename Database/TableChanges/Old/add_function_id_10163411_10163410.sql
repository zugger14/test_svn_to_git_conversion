

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10163410)
	BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	VALUES (10163410, 'Nomination Schedule Update', 'Nomination Schedule Update', 10163400, NULL, NULL, NULL, 0)
	PRINT 'INSERTED 10163410 - Nomination Schedule Update.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10163411 - Update Invoice Status already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10163411)
	BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	VALUES (10163411, 'Nomination Schedule Delete', 'Nomination Schedule Delete', 10163400, NULL, NULL, NULL, 0)
	PRINT 'INSERTED 10163411 - Nomination Schedule Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10163411 - Update Invoice Status already EXISTS.'
END

GO

