IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10234413)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10234413, 'Unprocess', 'Unprocess/Unmatch Hedges', 10234400, '', NULL, NULL, 1)
	PRINT ' Inserted 10234413 - Unprocess.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10234413 - Unprocess already EXISTS.'
END
