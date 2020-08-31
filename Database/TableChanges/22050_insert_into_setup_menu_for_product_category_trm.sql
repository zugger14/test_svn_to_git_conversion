--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20010500 AND sm.product_category = 10000000)
BEGIN
	INSERT INTO setup_menu(function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
	VALUES (20010500, 'Setup Book Tag Name', 10100000, 1, 0, 0, 10000000)
	PRINT ' Setup Menu 20010500 inserted.'
END
ELSE
BEGIN
	PRINT 'Setup Menu 20010500 already EXISTS.'
END