IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10105800 AND product_category = 10000000)
BEGIN
    INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,  menu_order, menu_type)
    VALUES (10105800, 'windowSetupCounterparty', 'Setup Counterparty', '', 1, 10101099, 10000000, 45, 0)
    PRINT 'SetupCounterparty - 10105800 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Function ID 10105800 already exists.'
END 