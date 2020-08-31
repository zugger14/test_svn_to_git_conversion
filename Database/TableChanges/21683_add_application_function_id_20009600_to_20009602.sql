--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20009600)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20009600, 'Setup User Defined View', 'Setup User Defined View', NULL, '_setup/setup_user_defined_view/setup.user.defined.view.php', NULL, NULL, 0)
	PRINT ' Inserted 20009600 - Setup User Defined View.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20009600 - Setup User Defined View already EXISTS.'
END

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20009600 AND sm.product_category = 10000000)
BEGIN
	INSERT INTO setup_menu(function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
	VALUES (20009600, 'Setup User Defined View', 10104099, 1, 0, 0, 10000000)
	PRINT ' Setup Menu 20009600 inserted.'
END
ELSE
BEGIN
	PRINT 'Setup Menu 20009600 already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20009601)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20009601, 'Add/Save', '', 20009600, '', NULL, NULL, 0)
	PRINT ' Inserted 20009601 - Add/Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20009601 - Add/Save already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20009602)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20009602, 'Delete', '', 20009600, '', NULL, NULL, 0)
	PRINT ' Inserted 20009602 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20009602 - Delete already EXISTS.'
END

                    

                    
                    