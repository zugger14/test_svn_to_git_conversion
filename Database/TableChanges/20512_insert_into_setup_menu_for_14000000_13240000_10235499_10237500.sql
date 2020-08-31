--Insert into application_functions
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 13240000 AND sm.product_category = 14000000)
BEGIN
	INSERT INTO setup_menu(function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
	VALUES (13240000, 'Derivative Accounting', 14000000, 1, 1, 0, 14000000)
	PRINT ' Setup Menu 13240000 inserted.'
END
ELSE
BEGIN
	PRINT 'Setup Menu 13240000 already EXISTS.'
END


--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 10235499 AND sm.product_category = 14000000)
BEGIN
	INSERT INTO setup_menu(function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
	VALUES (10235499, 'Accounting', 13240000, 1, 1, 0, 14000000)
	PRINT ' Setup Menu 10235499 inserted.'
END
ELSE
BEGIN
	PRINT 'Setup Menu 10235499 already EXISTS.'
END


--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 10237500 AND sm.product_category = 14000000)
BEGIN
	INSERT INTO setup_menu(function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
	VALUES (10237500, 'Close Accounting Period', 10235499, 1, 0, 0, 14000000)
	PRINT ' Setup Menu 10237500 inserted.'
END
ELSE
BEGIN
	PRINT 'Setup Menu 10237500 already EXISTS.'
END