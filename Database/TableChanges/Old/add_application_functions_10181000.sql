IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10181000)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	VALUES (10181000, 'Run MTM Process', 'Run MTM Process', '10180000', NULL, NULL, NULL, 0 )
	PRINT 'INSERTED 10181000 - Run MTM Process.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10181000 - Run MTM Process already EXISTS.'
END