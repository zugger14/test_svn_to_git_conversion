--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20007900)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20007900, 'Buy Sell Match', 'Buy Sell Match', NULL, '_deal_capture/buy_sell/buysell.match.php', NULL, NULL, 0)
	PRINT ' Inserted 20007900 - Buy Sell Match.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20007900 - Buy Sell Match already EXISTS.'
END

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20007900 AND sm.product_category = 14000000)
BEGIN
	INSERT INTO setup_menu(function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
	VALUES (20007900, 'Buy Sell Match', 12130000, 1, 0, 0, 14000000)
	PRINT ' Setup Menu 20007900 inserted.'
END
ELSE
BEGIN
	PRINT 'Setup Menu 20007900 already EXISTS.'
END



IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20007901)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20007901, 'Add/Save', '', 20007900, '', NULL, NULL, 0)
	PRINT ' Inserted 20007901 - Add/Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20007901 - Add/Save already EXISTS.'
END
GO

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20007902)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20007902, 'Delete', '', 20007900, '', NULL, NULL, 0)
	PRINT ' Inserted 20007902 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20007902 - Delete already EXISTS.'
END
GO

---Other Templates
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20007903)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20007903, 'Buy Sell Match Filter1', '', 20007900, '', NULL, NULL, 0)
	PRINT ' Inserted 20007903 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20007903 - Deal Match Filter1 already EXISTS.'
END
GO

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20007904)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20007904, 'Buy Sell Match Filter2', '', 20007900, '', NULL, NULL, 0)
	PRINT ' Inserted 20007904 - Deal Match Filter2.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20007904 - Deal Match Filter2 already EXISTS.'
END
GO
