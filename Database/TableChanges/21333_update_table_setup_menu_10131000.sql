--Update setup_menu
UPDATE setup_menu
	SET display_name = 'Create and View Deal',
		parent_menu_id = 12130000,
		menu_type = 0,
		hide_show = 1
		WHERE [function_id] = 10131000
		AND [product_category]= 14000000
PRINT 'Updated Setup Menu.'
                    