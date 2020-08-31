IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10202201)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	VALUES (10202201, 'SAP Settlement Export ', 'SAP Settlement Export ', '10202200', NULL, NULL, NULL, 0 )
	PRINT 'INSERTED 10202201 - SAP Settlement Export .'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10202201 - SAP Settlement Export  already EXISTS.'
END