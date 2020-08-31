IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10202300 AND product_category = 10000000)
BEGIN
    INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,
                           menu_order, menu_type)
    VALUES (10202300, 'windowRunProcess', 'Run Process', '', 1, 10200000, 10000000, 199, 0)
    PRINT 'Run Process - 10202300 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Function ID 10202300 already exists.'
END
