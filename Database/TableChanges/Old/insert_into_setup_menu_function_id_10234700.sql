IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10234700 AND product_category = 10000000)
BEGIN
    INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,
                           menu_order, menu_type)
    VALUES (10234700, 'windowMaintainTransactionsTagging', 'Maintain Transactions Tagging', '', 1, 10230095, 10000000, '', 0)
    PRINT 'Maintain Transactions Tagging - 10234700 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Function ID 10234700 already exists.'
END

IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10234700 AND product_category = 13000000)
BEGIN
    INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,
                           menu_order, menu_type)
    VALUES (10234700, 'windowMaintainTransactionsTagging', 'Maintain Transactions Tagging', '', 1, 10131099, 13000000, '', 0)
    PRINT 'Maintain Transactions Tagging - 10234700 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Function ID 10234700 already exists.'
END

IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10234700 AND product_category = 12000000)
BEGIN
    INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,
                           menu_order, menu_type)
    VALUES (10234700, 'windowMaintainTransactionsTagging', 'Maintain Transactions Tagging', '', 1, 10230095, 12000000, '', 0)
    PRINT 'Maintain Transactions Tagging - 10234700 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Function ID 10234700 already exists.'
END


--SELECT * FROM setup_menu WHERE display_name LIKE '%Maintain Transactions Tagging%'