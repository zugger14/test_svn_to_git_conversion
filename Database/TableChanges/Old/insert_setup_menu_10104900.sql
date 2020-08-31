-- Script to Insert menu
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10104900 AND product_category = 10000000)
BEGIN
    INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,
                           menu_order, menu_type)
    VALUES (10104900, 'windowEmailSetup', 'Compose Email', '', 1, 10100000, 10000000, 44, 0)
    PRINT 'Compose Email - 10104900 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Function ID 10104900 already exists.'
END