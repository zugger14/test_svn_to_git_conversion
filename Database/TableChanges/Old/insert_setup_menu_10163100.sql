IF NOT EXISTS(SELECT * FROM setup_menu WHERE function_id = 10163100 AND product_category = 10000000)
BEGIN
 	INSERT INTO setup_menu(function_id, display_name, parent_menu_id, window_name, product_category, menu_order, hide_show)
	VALUES (10163100, 'E-tag', 10160000, 'windowEtagMain', 10000000, 100, 1)
 	PRINT ' Inserted 10163100 - E-tag.'
END
ELSE
BEGIN
	PRINT 'setup_menu FunctionID 10163100 - E-tag already EXISTS.'
END