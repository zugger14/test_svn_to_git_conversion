--Excel Add-in - Menu Group
--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20010000 AND sm.product_category = 10000000)
BEGIN
	INSERT INTO setup_menu(function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
	VALUES (20010000, 'Excel Add-in', 10100000, 1, 1, 0, 10000000)
	PRINT ' Setup Menu 20010000 inserted.'
END
ELSE
BEGIN
	PRINT 'Setup Menu 20010000 already EXISTS.'
END

--Excel Document Generation - Menu
--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20010100)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20010100, 'Excel Document Generation', 'Excel Document Generation', NULL, '_reporting/view_report/view.report.php?mode=document_generation', NULL, NULL, 0)
	PRINT ' Inserted 20010100 - Excel Document Generation.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20010100 - Excel Document Generation already EXISTS.'
END

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20010100 AND sm.product_category = 10000000)
BEGIN
	INSERT INTO setup_menu(function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
	VALUES (20010100, 'Excel Document Generation', 20010000, 1, 0, 0, 10000000)
	PRINT ' Setup Menu 20010100 inserted.'
END
ELSE
BEGIN
	PRINT 'Setup Menu 20010100 already EXISTS.'
END

--Calculation Engine - Menu
--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20010200)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20010200, 'Calculation Engine', 'Calculation Engine', NULL, '_reporting/view_report/view.report.php?mode=calculation_engine', NULL, NULL, 0)
	PRINT ' Inserted 20010200 - Calculation Engine.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20010200 - Calculation Engine already EXISTS.'
END

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20010200 AND sm.product_category = 10000000)
BEGIN
	INSERT INTO setup_menu(function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
	VALUES (20010200, 'Calculation Engine', 20010000, 1, 0, 0, 10000000)
	PRINT ' Setup Menu 20010200 inserted.'
END
ELSE
BEGIN
	PRINT 'Setup Menu 20010200 already EXISTS.'
END

                    