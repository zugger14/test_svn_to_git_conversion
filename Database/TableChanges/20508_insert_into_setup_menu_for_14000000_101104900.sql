--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 10104900 AND sm.product_category = 14000000)
BEGIN
	INSERT INTO setup_menu(function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
	VALUES (10104900, 'Compose Email', 10104099, 1, 0, 0, 14000000)
	PRINT ' Setup Menu 10104900 inserted.'
END
ELSE
BEGIN
	PRINT 'Setup Menu 10104900 already EXISTS.'
END
                    