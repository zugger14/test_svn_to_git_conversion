IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10163900 AND product_category = 10000000)
BEGIN
    INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
    VALUES (10163900, 'windowRouteGroup', 'Setup Route', '', 1, 10160000, 10000000, '', 0)
    PRINT 'Route Group - 10163900 INSERTED.'
END
ELSE
BEGIN
	UPDATE setup_menu 
	SET display_name = 'Setup Route'
	WHERE function_id = 10163900
    PRINT 'Function ID 10163900 already exists.'
END