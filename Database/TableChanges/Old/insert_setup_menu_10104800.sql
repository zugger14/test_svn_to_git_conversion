IF NOT EXISTS(SELECT * FROM setup_menu WHERE function_id = 10104800 AND product_category = 10000000)
BEGIN
 	INSERT INTO setup_menu(function_id, display_name, parent_menu_id, window_name, product_category, menu_order, hide_show)
	VALUES (10104800, 'Data Import/Export', 10100000, 'windowDataImportExport', 10000000, 41, 1)
 	PRINT ' Inserted 10104800 - Data Import/Export.'
END
ELSE
BEGIN
	PRINT 'setup_menu FunctionID 10104800 - Data Import/Export already EXISTS.'
END

IF NOT EXISTS(SELECT * FROM setup_menu WHERE function_id = 10104800 AND product_category = 15000000)
BEGIN
 	INSERT INTO setup_menu(function_id, display_name, parent_menu_id, window_name, product_category, menu_order, hide_show)
	VALUES (10104800, 'Data Import/Export', 10100000, 'windowDataImportExport', 15000000, 40, 1)
 	PRINT ' Inserted 10104800 - Data Import/Export.'
END
ELSE
BEGIN
	PRINT 'setup_menu FunctionID 10104800 - Data Import/Export already EXISTS.'
END