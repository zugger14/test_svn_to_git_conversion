--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20007800 AND sm.product_category = 10000000)
BEGIN
    INSERT INTO setup_menu (function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
    VALUES (20007800, 'MTM Report', 10202200, 0, 0, 0, 10000000)
    PRINT ' Setup Menu 20007800 inserted.'
END
ELSE
BEGIN
    PRINT 'Setup Menu 20007800 already EXISTS.'
END

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 10235400 AND sm.product_category = 10000000)
BEGIN
    INSERT INTO setup_menu (function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
    VALUES (10235400, 'Journal Entry Report', 10202200, 0, 0, 0, 10000000)
    PRINT ' Setup Menu 10235400 inserted.'
END
ELSE
BEGIN
    PRINT 'Setup Menu 10235400 already EXISTS.'
END

GO