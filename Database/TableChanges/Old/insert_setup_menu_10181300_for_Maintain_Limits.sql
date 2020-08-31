IF NOT EXISTS(SELECT * FROM setup_menu WHERE function_id = 10181399 AND product_category = 10000000)
BEGIN
 	INSERT INTO setup_menu(function_id, display_name, parent_menu_id, window_name, product_category, menu_order, hide_show, menu_type)
	VALUES (10181399, 'Run Limits', 10180000, '', 10000000, 100, 1, 1)
 	PRINT 'Inserted Menu 10181399 - Run Limits'
END
ELSE
BEGIN
	PRINT 'Menu 10181399 - Run Limits already exists.'
END

IF NOT EXISTS(SELECT * FROM setup_menu WHERE function_id = 10181300 AND product_category = 10000000)
BEGIN
 	INSERT INTO setup_menu(function_id, display_name, parent_menu_id, window_name, product_category, menu_order, hide_show)
	VALUES (10181300, 'Setup Limit', 10181399, 'LimitTrackingScreen', 10000000, 100, 1)
 	PRINT 'Inserted Menu 10181300 - Setup Limit'
END
ELSE
BEGIN
	UPDATE setup_menu
		set display_name = 'Setup Limit'
		WHERE function_id = 10181300 AND product_category = 10000000
	PRINT 'Menu 10181300 - Setup Limit already exists.'
END