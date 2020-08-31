IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10182500 AND product_category = 10000000)
BEGIN
    INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,
                           menu_order, menu_type)
    VALUES (10182500, 'windowWhatIfScenario', 'Setup What If Scenario', '', 1, 10183499, 10000000, 200, 0)
    PRINT 'Setup What If Scenario - 10182500 INSERTED.'
END
ELSE
BEGIN
	UPDATE setup_menu
		set display_name = 'Setup What If Scenario'
		WHERE function_id = 10182500 AND product_category = 10000000

    PRINT 'Function ID 10182500 already exists.'
END
GO
