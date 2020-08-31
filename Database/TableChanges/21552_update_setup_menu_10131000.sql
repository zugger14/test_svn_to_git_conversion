UPDATE setup_menu
	SET display_name = 'Deal Capture',
		parent_menu_id = 13000000,
		menu_type = 1,
		hide_show = 1
		WHERE [function_id] = 10130000
		AND [product_category]= 13000000
PRINT 'Updated Setup Menu.'
