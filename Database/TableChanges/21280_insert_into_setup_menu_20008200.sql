--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20008200 AND sm.product_category = 10000000)
BEGIN
	INSERT INTO setup_menu(function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
	VALUES (20008200, 'Setup Storage Contract', 10210000, 1, 0, 0, 10000000)
	PRINT ' Setup Menu 20008200 inserted.'
END
ELSE
BEGIN
	PRINT 'Setup Menu 20008200 already EXISTS.'
END