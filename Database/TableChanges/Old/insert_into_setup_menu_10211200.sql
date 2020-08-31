IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10211200 AND product_category = 13000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10211200, 'windowMaintainContract', 'Setup Standard Contract', 1, 10101099, 13000000, 2, 0)
END