IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10106300)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path)
	VALUES (10106300, 'Data Import/Export New UI', 'Data Import/Export New UI', '10106100', NULL, NULL, '_setup/data_import_export/data.import.export.php' )
	PRINT 'INSERTED 10106300 - Data Import/Export New UI.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10106300 - Data Import/Export New UI already EXISTS.'
END