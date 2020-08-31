--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20008100)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20008100, 'Template Mapping Privilege', 'Template Mapping Privilege', NULL, '_setup/template_mapping_privilege/template.mapping.privilege.php', NULL, NULL, 0)
	PRINT ' Inserted 20008100 - Template Mapping Privilege.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20008100 - Template Mapping Privilege already EXISTS.'
END

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20008100 AND sm.product_category = 10000000)
BEGIN
	INSERT INTO setup_menu(function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
	VALUES (20008100, 'Template Mapping Privilege', 10106499, 1, 0, 0, 10000000)
	PRINT ' Setup Menu 20008100 inserted.'
END
ELSE
BEGIN
	PRINT 'Setup Menu 20008100 already EXISTS.'
END
                    
--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20008101)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20008101, 'Add/Save', 'Add/Save', 20008100, '', NULL, NULL, 0)
	PRINT ' Inserted 20008101 - Add/Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20008101 - Add/Save already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20008102)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20008102, 'Delete', '', 20008100, '', NULL, NULL, 0)
	PRINT ' Inserted 20008102 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20008102 - Delete already EXISTS.'
END