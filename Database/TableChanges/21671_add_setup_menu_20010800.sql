--Insert into setup_menu - 20010800
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20010800 AND sm.product_category = 10000000)
BEGIN
    INSERT INTO setup_menu (function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
    VALUES (20010800, 'Run Margin Analysis', 10181199, 1, 0, 0, 10000000)
    PRINT ' Setup Menu 20010800 inserted.'
END
ELSE
BEGIN
    PRINT 'Setup Menu 20010800 already EXISTS.'
END     


UPDATE setup_menu
SET display_name = 'Run Margin Analysis',
    parent_menu_id = 10190000
    WHERE [function_id] = 20010800
    AND [product_category]= 10000000
PRINT 'Updated Setup Menu.' 

