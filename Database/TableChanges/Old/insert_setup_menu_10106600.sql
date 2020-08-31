IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10106600 AND product_category = 10000000)
BEGIN
    INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,
                           menu_order, menu_type)
    VALUES (10106600, 'windowRulesWorkflow', 'Setup Rule Workflow', '', 1, 10100000, 10000000, 52, 0)
    PRINT 'Setup Rule Workflow - 10106600 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Function ID 10106600 already exists.'
END