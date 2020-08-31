IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131036)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10131036, 'Delete', 'Delete Scheduled Deal Row', 10131028, '', NULL, NULL, 0)
	PRINT ' Inserted 10131036 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131036 - Delete already EXISTS.'
END