IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 12103200 AND product_category = 14000000)
BEGIN
    INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,
                           menu_order, menu_type)
    VALUES (12103200, 'windowMaintainRecAssignmentPriority', 'Maintain Rec Assignment Priority', '', 1, 12100000, 14000000, '', 0)
    PRINT 'Maintain Rec Assignment Priority - 12103200 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Function ID 12103200 already exists.'
END