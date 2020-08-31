IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10180000)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	VALUES (10180000, 'Valuation And Risk Analysis', 'Valuation And Risk Analysis', '10000000', NULL, NULL, NULL, 0 )
	PRINT 'INSERTED 10180000 - Valuation And Risk Analysis.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10180000 - Valuation And Risk Analysis already EXISTS.'
END