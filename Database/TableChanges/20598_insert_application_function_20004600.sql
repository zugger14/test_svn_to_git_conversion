--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20004600)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20004600, 'Setup DST', '', NULL, '', NULL, NULL, 0)
	PRINT ' Inserted 20004600 - Setup DST.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20004600 - Setup DST already EXISTS.'
END

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20004600 AND sm.product_category = 10000000)
BEGIN
	INSERT INTO setup_menu(function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
	VALUES (20004600, 'Setup DST', 10101099, 1, 0, 0, 10000000)
	PRINT ' Setup Menu 20004600 inserted.'
END
ELSE
BEGIN
	PRINT 'Setup Menu 20004600 already EXISTS.'
END


update
application_functions
set
file_path = '_setup/setup_dst/setup.dst.php'
where
function_id = 20004600     


IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20004601)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20004601, 'Add/Save', '', 20004600, '', NULL, NULL, 0)
	PRINT ' Inserted 20004601 - Add/Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20004601 - Add/Save already EXISTS.'
END


--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20004602)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20004602, 'Delete', '', 20004600, '', NULL, NULL, 0)
	PRINT ' Inserted 20004602 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20004602 - Delete already EXISTS.'
END
 