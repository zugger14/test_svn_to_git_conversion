--Update setup_menu
UPDATE setup_menu
	SET display_name = 'Jurisdiction/Market',
		parent_menu_id = 14100000,
		menu_type = 0,
		hide_show = 1
		WHERE [function_id] = 14100100
		AND [product_category]= 14000000
PRINT 'Updated Setup Menu.'

