IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10131000 AND product_category = 13000000)
BEGIN
	INSERT INTO setup_menu(function_id, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10131000, 'Create and View Deal', 1, 10130000, 13000000, 50, 0)
END