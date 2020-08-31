--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20013800 AND sm.product_category = 10000000)
BEGIN
    INSERT INTO setup_menu (function_id, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
    VALUES (20013800, 'Regression Testing', 1, 10100000, 10000000, 0, 1)
    PRINT 'Setup Menu 20013800 inserted.'
END
ELSE
BEGIN
    PRINT 'Setup Menu 20013800 already EXISTS.'
END
