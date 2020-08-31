IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131019)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	VALUES (10131019, 'Copy', 'Copy', '10131000', NULL, NULL, NULL, 1)
	PRINT 'INSERTED 10131019 - Copy.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131019 - Copy already EXISTS.'
END