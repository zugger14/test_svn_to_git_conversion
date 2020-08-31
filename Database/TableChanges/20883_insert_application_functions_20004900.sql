--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20004900)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20004900, 'Form Builder', 'Form Builder', NULL, '_setup/form_template_builder/form.template.builder.php', NULL, NULL, 0)
	PRINT ' Inserted 20004900 - Form Builder.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20004900 - Form Builder already EXISTS.'
END

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20004900 AND sm.product_category = 10000000)
BEGIN
	INSERT INTO setup_menu(function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
	VALUES (20004900, 'Form Builder', 10104099, 1, 0, 0, 10000000)
	PRINT ' Setup Menu 20004900 inserted.'
END
ELSE
BEGIN
	PRINT 'Setup Menu 20004900 already EXISTS.'
END
                    