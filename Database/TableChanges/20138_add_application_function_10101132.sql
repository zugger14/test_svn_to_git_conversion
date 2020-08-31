--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101132)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10101132, 'Migrate', 'Counterparty Credit Info - Migrate', 10101122, '', NULL, NULL, 0)
	PRINT ' Inserted 10101132 - Migrate.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101132 - Migrate already EXISTS.'
END