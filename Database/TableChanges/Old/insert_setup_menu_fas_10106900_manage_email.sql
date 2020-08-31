--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 10106900 AND sm.product_category = 13000000)
BEGIN
	INSERT INTO setup_menu(function_id, display_name, parent_menu_id, hide_show, menu_type, product_category, menu_order)
	VALUES (10106900, 'Manage Email', 10100000, 1, 0, 13000000, 51)
	PRINT ' Setup Menu 10106900 inserted.'
END
ELSE
BEGIN
	PRINT 'Setup Menu 10106900 already EXISTS.'
END