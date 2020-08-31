IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211130)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	VALUES (10211130, 'Charge Type Formula', 'Charge Type Formula', '10211115', NULL, NULL, NULL, 0 )
	PRINT 'INSERTED 10211130 - Charge Type Formula.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211130 - Charge Type Formula already EXISTS.'
END