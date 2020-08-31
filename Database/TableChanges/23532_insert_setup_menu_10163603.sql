IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10163603 AND product_category = 10000000)
BEGIN
    INSERT INTO setup_menu(function_id, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
    VALUES (10163603, 'Bookout/Back to Back', 1, 10161499, 10000000, 1, 0)
END
ELSE
BEGIN
	UPDATE setup_menu
		SET display_name = 'Bookout/Back to Back'
	WHERE function_id = 10163603
END