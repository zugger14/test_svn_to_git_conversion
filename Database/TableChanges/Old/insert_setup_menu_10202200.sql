IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10202200 AND product_category = 10000000)
BEGIN
    INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,
                           menu_order, menu_type)
    VALUES (10202200, 'windowViewReport', 'View Report', '', 1, 10200000, 10000000, 200, 0)
    PRINT 'View Report - 10202200 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Function ID 10202200 already exists.'
END