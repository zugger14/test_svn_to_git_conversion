--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10166800)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10166800, 'Run Generation Process', 'Run Generation Process', NULL, '_scheduling_delivery/run_generation_process/run.generation.process.php', NULL, NULL, 0)
	PRINT ' Inserted 10166800 - Run Generation Process.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10166800 - Run Generation Process already EXISTS.'
END

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 10166800 AND sm.product_category = 10000000)
BEGIN
	INSERT INTO setup_menu(function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
	VALUES (10166800, 'Run Generation Process', 10161299, 1, 0, 0, 10000000)
	PRINT ' Setup Menu 10166800 inserted.'
END
ELSE
BEGIN
	PRINT 'Setup Menu 10166800 already EXISTS.'
END