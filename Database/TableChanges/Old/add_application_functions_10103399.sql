IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103399)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	VALUES (10103399, 'Setup Contract Components ', 'Setup Contract Components ', '10100000', NULL, NULL, NULL, 0 )
	PRINT 'INSERTED 10103399 - Setup Contract Components .'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10103399 - Setup Contract Components  already EXISTS.'
END
