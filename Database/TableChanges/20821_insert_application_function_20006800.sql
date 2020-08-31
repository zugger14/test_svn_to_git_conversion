--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20006800)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20006800, 'Archive Data', 'Archive Data', NULL, '_setup/manage_data/archive.data.php', NULL, NULL, 0)
	PRINT ' Inserted 20006800 - Archive Data.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20006800 - Archive Data already EXISTS.'
END