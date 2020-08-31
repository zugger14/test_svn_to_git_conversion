IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 10105000 AND sm.product_category = 13000000)
BEGIN
    INSERT INTO setup_menu (function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
    VALUES (10105000, 'Setup Menu', 10100000, 1, 0, 0, 13000000)
    PRINT ' Setup Menu 10105000 inserted.'
END
ELSE
BEGIN
    PRINT 'Setup Menu 10105000 already EXISTS.'
END     