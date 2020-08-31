--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201900)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10201900, 'Data Import/Export Audit Report', 'Data Import/Export Audit Report', NULL, '', NULL, NULL, 0)
	PRINT ' Inserted 10201900 - Data Import/Export Audit Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10201900 - Data Import/Export Audit Report already EXISTS.'
END

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 10201900 AND sm.product_category = 14000000)
BEGIN
	INSERT INTO setup_menu(function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
	VALUES (10201900, 'Data Import/Export Audit Report', 10202200, 0, 0, 0, 14000000)
	PRINT ' Setup Menu 10201900 inserted.'
END
ELSE
BEGIN
	PRINT 'Setup Menu 10201900 already EXISTS.'
END
                    