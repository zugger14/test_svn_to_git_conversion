--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10202100)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10202100, 'Message Board Log Report', 'Message Board Log Report', NULL, '', NULL, NULL, 0)
	PRINT ' Inserted 10202100 - Message Board Log Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10202100 - Message Board Log Report already EXISTS.'
END

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 10202100 AND sm.product_category = 14000000)
BEGIN
	INSERT INTO setup_menu(function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
	VALUES (10202100, 'Message Board Log Report', 10202200, 0, 0, 0, 14000000)
	PRINT ' Setup Menu 10202100 inserted.'
END
ELSE
BEGIN
	PRINT 'Setup Menu 10202100 already EXISTS.'
END
                    