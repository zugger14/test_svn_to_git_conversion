IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10166300 AND product_category = 10000000)
BEGIN
    INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,
                           menu_order, menu_type)
    VALUES (10166300, 'windowCopyNomination', 'Copy Nomination', '', 1, 10160000, 10000000, 136, 1)
    PRINT 'Setup menu 10166300 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Setup menu 10166300 already exists.'
END