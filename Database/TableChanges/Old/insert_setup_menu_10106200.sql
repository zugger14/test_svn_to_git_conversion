DELETE FROM setup_menu WHERE function_id = 10106200 AND product_category = 10000000

IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10106200 AND product_category = 10000000)
BEGIN
    INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,
                           menu_order, menu_type)
    VALUES (10106200, 'windowSetupWeatherData', 'Setup Weather Data', '', 1, 10100000, 10000000, 113, 0)
    PRINT 'Setup menu 10106200 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Setup menu 10106200 already exists.'
END