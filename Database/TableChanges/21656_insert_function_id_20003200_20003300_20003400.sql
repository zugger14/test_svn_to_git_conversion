--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20003200 AND sm.product_category = 10000000)
BEGIN
	INSERT INTO setup_menu(function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
	VALUES (20003200, 'User Defined Table', 10100000, 1, 1, 0, 10000000)
	PRINT ' Setup Menu 20003200 inserted.'
END
ELSE
BEGIN
	PRINT 'Setup Menu 20003200 already EXISTS.'
END


--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20003300)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20003300, 'Setup User Defined Table', 'Setup User Defined Table', NULL, '_setup/user_defined_table/setup.user.defined.table.php', NULL, NULL, 0)
	PRINT ' Inserted 20003300 - Setup User Defined Table.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20003300 - Setup User Defined Table already EXISTS.'
END


--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20003300 AND sm.product_category = 10000000)
BEGIN
	INSERT INTO setup_menu(function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
	VALUES (20003300, 'Setup User Defined Table', 20003200, 1, 0, 0, 10000000)
	PRINT ' Setup Menu 20003300 inserted.'
END
ELSE
BEGIN
	PRINT 'Setup Menu 20003300 already EXISTS.'
END


--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20003301)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20003301, 'Add/Save', 'Add/Save', 20003300, '', NULL, NULL, 0)
	PRINT ' Inserted 20003301 - Add/Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20003301 - Add/Save already EXISTS.'
END


--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20003302)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20003302, 'Delete', 'Delete', 20003300, '', NULL, NULL, 0)
	PRINT ' Inserted 20003302 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20003302 - Delete already EXISTS.'
END


--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20003303)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20003303, 'Table Changes', 'Table Changes', 20003300, '', NULL, NULL, 0)
	PRINT ' Inserted 20003303 - Table Changes.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20003303 - Table Changes already EXISTS.'
END


--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20003304)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20003304, 'Import Rule', 'Import Rule', 20003300, '', NULL, NULL, 0)
	PRINT ' Inserted 20003304 - Import Rule.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20003304 - Import Rule already EXISTS.'
END


--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20003400)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20003400, 'View User Defined Table', 'View User Defined Table', NULL, '_setup/user_defined_table/view.user.defined.table.php', NULL, NULL, 0)
	PRINT ' Inserted 20003400 - View User Defined Table.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20003400 - View User Defined Table already EXISTS.'
END

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20003400 AND sm.product_category = 10000000)
BEGIN
	INSERT INTO setup_menu(function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
	VALUES (20003400, 'View User Defined Table', 20003200, 1, 0, 0, 10000000)
	PRINT ' Setup Menu 20003400 inserted.'
END
ELSE
BEGIN
	PRINT 'Setup Menu 20003400 already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20003401)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20003401, 'Add/Save', 'Add/Save', 20003400, '', NULL, NULL, 0)
	PRINT ' Inserted 20003401 - Add/Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20003401 - Add/Save already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20003402)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20003402, 'Delete', 'Delete', 20003400, '', NULL, NULL, 0)
	PRINT ' Inserted 20003402 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20003402 - Delete already EXISTS.'
END