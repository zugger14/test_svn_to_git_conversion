IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10122600 AND product_category = 10000000)
BEGIN
    INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,
                           menu_order, menu_type)
    VALUES (10122600, 'windowSetupAlertsSimple', 'Setup Simple Alert', '', 1, 10106699, 10000000, 49, 0)
    PRINT 'Setup Simple Alert - 10122600 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Function ID 10122600 already exists.'
END