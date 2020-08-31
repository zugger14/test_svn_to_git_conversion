--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 10106800 AND sm.product_category = 10000000)
BEGIN
	INSERT INTO setup_menu(function_id, display_name, parent_menu_id, hide_show, menu_type, product_category, menu_order)
	VALUES (10106800, 'Calendar', 10100000, 0, 0, 10000000, 111)
	PRINT ' Setup Menu 10106800 inserted.'
END
ELSE
BEGIN
	PRINT 'Setup Menu 10106800 already EXISTS.'
END