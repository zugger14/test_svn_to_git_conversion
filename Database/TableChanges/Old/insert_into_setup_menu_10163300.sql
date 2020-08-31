IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10163300 AND product_category = 10000000)
BEGIN
    INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,
                           menu_order, menu_type)
    VALUES (10163300, 'windowMapRateSchedules', 'Map Rate Schedules', '', 1, 10160000, 10000000, 107, 0)
    PRINT 'Map Rate Schedules - 10163300 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Function ID 10163300 already exists.'
END

select * from location_loss_factor