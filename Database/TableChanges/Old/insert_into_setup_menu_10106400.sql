IF NOT EXISTS (
	SELECT 1 from setup_menu WHERE window_name = 'windowTemplateFieldMapping' AND function_id = 10106400
)
BEGIN
	INSERT INTO setup_menu (
		function_id,
		window_name,
		display_name,
		default_parameter,
		hide_show,
		parent_menu_id,
		product_category,
		menu_order,
		menu_type
	)
	VALUES(
		'10106400',
		'windowTemplateFieldMapping',
		'Template Field Mapping',
		NULL,
		1,
		10100000,
		10000000,
		16,
		0
	)
END