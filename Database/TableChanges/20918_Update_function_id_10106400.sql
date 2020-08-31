--Update application_functions
UPDATE application_functions
	SET function_name = 'Template Deal Filter',
		function_desc = 'Template Deal Filter',
		func_ref_id = NULL,
		file_path = '_setup/template_field_mapping/template.field.mapping.php',
		function_parameter = NULL,
		module_type = NULL,
		book_required = 0
		WHERE [function_id] = 10106400
PRINT 'Updated Application Function.'

--Update setup_menu
UPDATE setup_menu
	SET display_name = 'Template Deal Filter',
		parent_menu_id = 10106499,
		menu_type = 0,
		hide_show = 1
		WHERE [function_id] = 10106400
		AND [product_category]= 10000000
PRINT 'Updated Setup Menu.'