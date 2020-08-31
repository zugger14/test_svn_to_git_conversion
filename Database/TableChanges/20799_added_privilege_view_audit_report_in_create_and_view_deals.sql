IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131016)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10131016, 'View Audit Report', 'View Audit Report', 10131000, '', NULL, NULL, 0)
	PRINT ' Inserted 10131016 - View Audit Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131016 - View Audit Report already EXISTS.'
END