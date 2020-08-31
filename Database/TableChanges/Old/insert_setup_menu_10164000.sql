IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10164000 AND product_category = 10000000)
BEGIN
    INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,
                           menu_order, menu_type)
    VALUES (10164000, 'windowUpdateWellheadVolume', 'Update Wellhead Volume', '', 1, 10160000, 10000000, 93, 0)
    PRINT 'Update Wellhead Volume - 10164100 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Function ID 10164000 already exists.'
END