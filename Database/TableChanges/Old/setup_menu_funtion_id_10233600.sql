IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10233600 AND product_category = 10000000)
BEGIN
    INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,menu_order, menu_type)
    VALUES (10233600, 'windowCloseMeasurement', 'Close Settlement Accounting Period', '', 1, 10220000, 10000000, 193, 0)
    PRINT 'Close Settlement Accounting Period - 10233600 INSERTED.'
END
ELSE
BEGIN
    UPDATE setup_menu
	SET window_name = 'windowCloseMeasurement',
        display_name = 'Close Settlement Accounting Period',
        hide_show = 1,
        parent_menu_id = 10220000
		WHERE  function_id = 10233600
        AND product_category = 10000000
        PRINT 'Close Settlement Accounting Period - 10233600 UPDATED.'
END