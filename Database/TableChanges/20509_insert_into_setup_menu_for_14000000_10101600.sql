--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 10101600 AND sm.product_category = 14000000)
BEGIN
	INSERT INTO setup_menu(function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
	VALUES (10101600, 'View Scheduled Job', 10100000, 1, 0, 0, 14000000)
	PRINT ' Setup Menu 10101600 inserted.'
END
ELSE
BEGIN
	PRINT 'Setup Menu 10101600 already EXISTS.'
END
                