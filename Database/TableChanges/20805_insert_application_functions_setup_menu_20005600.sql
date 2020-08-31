--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20005600)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20005600, 'Deal Transfer Rule', 'Deal Transfer Rule', NULL, '_setup/deal_trasfer_rule/deal.trasfer.rule.php', NULL, NULL, 0)
	PRINT ' Inserted 20005600 - Deal Transfer Rule.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20005600 - Deal Transfer Rule already EXISTS.'
END

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20005600 AND sm.product_category = 10000000)
BEGIN
	INSERT INTO setup_menu(function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
	VALUES (20005600, 'Deal Transfer Rule', 10104099, 1, 0, 0, 10000000)
	PRINT ' Setup Menu 20005600 inserted.'
END
ELSE
BEGIN
	PRINT 'Setup Menu 20005600 already EXISTS.'
END
                    