IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 12101700 AND product_category = 10000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES(12101700, 'windowSetupRenewableSource', 'Setup Renewable Source', 1, 10101099, 10000000, 2, 0)
END