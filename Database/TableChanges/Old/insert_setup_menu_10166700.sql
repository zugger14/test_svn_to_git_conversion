IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10166700)
BEGIN
    INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,
                           menu_order, menu_type)
    VALUES (10166700, 'windowGenerationReservePlanner', 'Generation Reserve Planner', '', 1, 10160000, 10000000, 245, 0)
    PRINT 'Setup menu 10166700 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Setup menu 10166700 already exists.'
END
