IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10163610 AND product_category = 10000000)
BEGIN
    INSERT INTO setup_menu(function_id, display_name, hide_show, parent_menu_id, product_category,menu_order, menu_type)
    VALUES (10163610, 'Deal Scheduling Match', 1, 10161499, 10000000, 1, 0)
END
ELSE
BEGIN
	UPDATE setup_menu 
		SET display_name = 'Deal Scheduling Match'
	WHERE function_id = 10163610
END

