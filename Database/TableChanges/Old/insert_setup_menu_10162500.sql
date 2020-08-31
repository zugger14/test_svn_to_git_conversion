-- Script to Insert menu
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10162500 AND product_category = 10000000)
BEGIN
    INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,
                           menu_order, menu_type)
    VALUES (10162500, 'windowRunInventoryCalc', 'Run Inventory Calc', '', 1, 10160000, 10000000, 136, 0)
    PRINT 'Run Inventory Calc - 10162500 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Function ID 10162500 already exists.'
END