--Update setup_menu
UPDATE setup_menu
	SET display_name = 'Regression Testing',
		parent_menu_id= '10100000',
		menu_type = 0,
		hide_show = 1
		WHERE [function_id] = 20009400
		AND [product_category]= 10000000
PRINT 'Updated Setup Menu.'