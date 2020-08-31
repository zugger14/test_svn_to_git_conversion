--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105000)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10105000, 'Setup Menu', 'Setup Menu', NULL, '_setup/setup_menu/setup.menu.php', NULL, NULL, 0)
	PRINT ' Inserted 10105000 - Setup Menu.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105000 - Setup Menu already EXISTS.'
END

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 10105000 AND sm.product_category = 10000000)
BEGIN
	INSERT INTO setup_menu(function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
	VALUES (10105000, 'Setup Menu', 10100000, 1, 0, 0, 10000000)
	PRINT ' Setup Menu 10105000 inserted.'
END
ELSE
BEGIN
	PRINT 'Setup Menu 10105000 already EXISTS.'
END