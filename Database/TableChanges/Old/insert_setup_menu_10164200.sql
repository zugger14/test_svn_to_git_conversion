IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10164200 AND product_category = 10000000)
BEGIN
    INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,
                           menu_order, menu_type)
    VALUES (10164200, 'windowRunAutoNumProcess', 'Run Auto Nom Process', '', 1, 10160000, 10000000, 112, 1)
    PRINT 'Setup menu 10164200 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Setup menu 10164200 already exists.'
END