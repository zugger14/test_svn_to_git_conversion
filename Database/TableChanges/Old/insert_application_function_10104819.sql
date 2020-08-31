IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104819)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	VALUES (10104819, 'Data Import\Export SSIS Parameters', 'Data Import\Export SSIS Parameters', '10104800', NULL, NULL, NULL, 0 )
	PRINT 'INSERTED 10104819 - Data Import\Export SSIS Parameters.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104819 - Data Import\Export SSIS Parameters already EXISTS.'
END