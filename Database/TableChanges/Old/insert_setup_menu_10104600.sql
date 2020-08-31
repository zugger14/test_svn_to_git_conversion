IF NOT EXISTS(SELECT * FROM setup_menu WHERE function_id = 10104600 AND product_category = 10000000)
BEGIN
 	INSERT INTO setup_menu(function_id, display_name, parent_menu_id, window_name, product_category, menu_order, hide_show, menu_type)
	VALUES (10104600, 'Setup Settlement Netting Group', 10100000, 'windowMaintainNettingGrp', 10000000, 17, 1, 0)
 	PRINT ' Inserted 10104600 - Setup Settlement Netting Group.'
END
ELSE
BEGIN
	UPDATE setup_menu
	SET
		display_name = 'Setup Settlement Netting Group',
		menu_type = 0
	WHERE function_id = 10104600
	PRINT 'setup_menu FunctionID 10104600 - Data Import/Export already EXISTS.'
END

IF NOT EXISTS(SELECT * FROM setup_menu WHERE function_id = 10104600 AND product_category = 15000000)
BEGIN
 	INSERT INTO setup_menu(function_id, display_name, parent_menu_id, window_name, product_category, menu_order, hide_show, menu_type)
	VALUES (10104600, 'Setup Settlement Netting Group', 10100000, 'windowMaintainNettingGrp', 15000000, 17, 1, 0)
 	PRINT ' Inserted 10104600 - Setup Settlement Netting Group.'
END
ELSE
BEGIN
	UPDATE setup_menu
	SET
		display_name = 'Setup Settlement Netting Group',
		menu_type = 0
	WHERE function_id = 10104600
	PRINT 'setup_menu FunctionID 10104600 - Data Import/Export already EXISTS.'
END


       
     
