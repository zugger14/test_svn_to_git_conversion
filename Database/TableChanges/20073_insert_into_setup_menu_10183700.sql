IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10183700 AND product_category = 10000000)
BEGIN
    INSERT INTO setup_menu(function_id, display_name, hide_show, parent_menu_id, product_category,menu_order, menu_type)
    VALUES (10183700, 'Calculate Margin Analysis', 1, 10181199, 10000000, 1, 0)
END