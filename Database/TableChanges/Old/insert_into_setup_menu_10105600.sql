IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10105600 AND product_category = 10000000)
BEGIN
    INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,
                           menu_order, menu_type)
    VALUES (10105600, 'windowNewFormulaBuilder', 'New Formula Builder', '', 1, 10100000, 10000000, 43, 0)
    PRINT 'New Formula Builder - 10105600 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Function ID 10105600 already exists.'
END
