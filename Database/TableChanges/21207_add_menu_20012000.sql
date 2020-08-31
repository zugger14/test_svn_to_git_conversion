--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20002300 AND sm.product_category = 14000000)
BEGIN
    INSERT INTO setup_menu (function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
    VALUES (20002300, 'Deal Type Pricing Mapping', 10106499, 1, 0, 0, 14000000)
    PRINT ' Setup Menu 20002300 inserted.'
END
ELSE
BEGIN
    PRINT 'Setup Menu 20002300 already EXISTS.'
END