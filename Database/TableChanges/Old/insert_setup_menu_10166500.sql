IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10166500)
BEGIN
    INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,
                           menu_order, menu_type)
    VALUES (10166500, 'windowActualizeSchedules', 'Actualize Schedules', '', 1, 10160000, 10000000, 243, 0)
    PRINT 'Setup menu 10106300 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Setup menu 10166500 already exists.'
END
