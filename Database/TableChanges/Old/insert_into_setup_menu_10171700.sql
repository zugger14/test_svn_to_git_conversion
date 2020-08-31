IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10171700 AND product_category = 10000000)
BEGIN
    INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,
                           menu_order, menu_type)
    VALUES (10171700, 'windowSendConfirmation', 'Send Confirmation', '', 1, 10170000, 10000000, 105, 0)
    PRINT 'Send Confirmation - 10171700 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Function ID 10171700 already exists.'
END

