IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 12121600 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (12121600, 'Finalize Committed RECs', 1, 12130000, 14000000, 1, 1)
END