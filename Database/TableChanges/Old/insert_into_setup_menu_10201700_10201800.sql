IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10201700)
BEGIN
    INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
    VALUES (10201700, 'WindowRunReportGroup', 'Run Report Group', '', 1, 10200000, 10000000, '', 0)
    PRINT 'Run Report Group - 10201700 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Function ID 10201700 already exists.'
END

IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10201800)
BEGIN
    INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
    VALUES (10201800, 'WindowReportGroupManager', 'Report Group Manager', '', 1, 10200000, 10000000, '', 0)
    PRINT 'Report Group Manager - 10201800 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Function ID 10201800 already exists.'
END

