IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10221313)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	VALUES (10221313, 'Export Invoice', 'Export Invoice', '10221300', NULL, NULL, NULL, 0 )
	PRINT 'INSERTED 10221313 - Export Invoice.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10221313 - Export Invoice already EXISTS.'
END