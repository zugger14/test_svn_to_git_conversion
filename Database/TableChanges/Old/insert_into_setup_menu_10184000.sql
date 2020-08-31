IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10184000 and product_category=10000000)
	BEGIN
	insert into setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
    values(10184000, NULL,'Run MTM Simulation' ,1, 10181500, 10000000, 134, 1)
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131600 already EXISTS.'
END




