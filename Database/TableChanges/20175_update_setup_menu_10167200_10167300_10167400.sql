UPDATE setup_menu
	SET display_name = 'Forecast Parameters Mapping',
		parent_menu_id = 10161699,
		menu_type = 0,
		hide_show = 1
		WHERE [function_id] = 10167200
		AND [product_category]= 10000000
PRINT 'Updated Setup Menu.'

UPDATE setup_menu
	SET display_name = 'Setup Forecast Model',
		parent_menu_id = 10161699,
		menu_type = 0,
		hide_show = 1
		WHERE [function_id] = 10167300
		AND [product_category]= 10000000
PRINT 'Updated Setup Menu.'

UPDATE setup_menu
	SET display_name = 'Run Forecasting',
		parent_menu_id = 10161699,
		menu_type = 0,
		hide_show = 1
		WHERE [function_id] = 10167400
		AND [product_category]= 10000000
PRINT 'Updated Setup Menu.'