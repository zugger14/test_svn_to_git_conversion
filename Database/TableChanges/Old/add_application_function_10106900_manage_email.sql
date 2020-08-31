
--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10106900)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10106900, 'Manage Email', 'Manage Email', NULL, '_setup/manage_email/manage.email.php', '', '', 0)
	PRINT ' Inserted 10106900 - Manage Email.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10106900 - Manage Email already EXISTS.'
END

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 10106900 AND sm.product_category = 10000000)
BEGIN
	INSERT INTO setup_menu(function_id, display_name, parent_menu_id, hide_show, menu_type, product_category, menu_order)
	VALUES (10106900, 'Manage Email', 10100000, 1, 0, 10000000, 51)
	PRINT ' Setup Menu 10106900 inserted.'
END
ELSE
BEGIN
	PRINT 'Setup Menu 10106900 already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10106910)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10106910, 'Add/Save', 'Add/Save', 10106900, '', '', '', 0)
	PRINT ' Inserted 10106910 - Add/Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10106910 - Add/Save already EXISTS.'
END
--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10106911)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10106911, 'Delete', 'Delete', 10106900, '', '', '', 0)
	PRINT ' Inserted 10106911 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10106911 - Delete already EXISTS.'
END
--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10106920)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10106920, 'Map/Unmap Email', 'Map/Unmap Email', 10106900, '', '', '', 0)
	PRINT ' Inserted 10106920 - Map/Unmap Email.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10106920 - Map/Unmap Email already EXISTS.'
END

