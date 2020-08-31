IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10106300)
BEGIN
    INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,
                           menu_order, menu_type)
    VALUES (10106300, 'windowDataImportNewUI', 'Data Import/Export New UI', '', 1, 10100000, 10000000, 112, 0)
    PRINT 'Setup menu 10106300 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Setup menu 10106300 already exists.'
END