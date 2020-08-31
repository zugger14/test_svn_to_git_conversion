IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10107000 AND product_category = 13000000)
BEGIN
    INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,  menu_order, menu_type)
    VALUES (10107000, 'Setup As of Date', 'Setup As of Date', '', 1, 10101099, 13000000, 21, 0)
    PRINT 'SetupCounterparty - 10105800 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Function ID 10107000 already exists.'
END 