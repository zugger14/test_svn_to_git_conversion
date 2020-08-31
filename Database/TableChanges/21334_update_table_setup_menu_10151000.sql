--Update setup_menu
UPDATE setup_menu
	SET display_name = 'View Price',
		parent_menu_id = 10150000,
		menu_type = 0,
		hide_show = 1
		WHERE [function_id] = 10151000
		AND [product_category]= 14000000
PRINT 'Updated Setup Menu.'
                    