--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131029)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10131029, 'Setup Generation', 'Setup Generation', 10131000, '', NULL, NULL, 0)
	PRINT ' Inserted 10131029 - Setup Generation.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131029 - Setup Generation already EXISTS.'
END