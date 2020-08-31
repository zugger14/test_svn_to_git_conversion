IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10131028 AND product_category = 10000000)
BEGIN
	INSERT INTO setup_menu(function_id, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10131028, 'Schedule Deal', 0, 10132000, 10000000, 50, 0)
END