IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE dbo.setup_menu.function_id = 13102000 AND dbo.setup_menu.product_category = 13000000)
BEGIN
	INSERT INTO setup_menu (function_id
						, window_name
						, display_name
						, default_parameter
						, hide_show
						, parent_menu_id
						, product_category
						, menu_order
						, menu_type)
	SELECT 13102000, 'windowGenericMapping', 'Generic Mapping', NULL, 1, 10100000, 13000000, 34, 0
END 

UPDATE setup_menu SET parent_menu_id = 13170000 WHERE function_id = 13102000 AND product_category = 13000000