-- Script to Insert menu
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10131300 AND product_category = 10000000)
BEGIN
    INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,
                           menu_order, menu_type)
    VALUES (10131300, 'windowImportDataDeal', 'Import Data/Import Price', '', 1, 10100000, 10000000, 51, 0)
    PRINT 'Import Data - 10131300 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Function ID 10131300 already exists.'
END