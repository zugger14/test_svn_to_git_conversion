IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10233411)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10233411, 'Delete', 'Run Measurement Delete', 10233400, '', NULL, NULL, 0)
	PRINT ' Inserted 10233411 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10233411 - Delete already EXISTS.'
END
GO