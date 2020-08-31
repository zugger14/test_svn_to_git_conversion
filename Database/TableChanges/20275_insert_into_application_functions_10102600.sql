IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10202600)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10202600, 'Excel Addin Report Manager', 'Excel Addin Report Manager', NULL, '_reporting/report_manager_excel/report.manager.excel.php', NULL, NULL, 0)
	PRINT ' Inserted 10202600 -  Excel Addin Report Manager.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10202600 - Excel Addin Report Manager already EXISTS.'
END