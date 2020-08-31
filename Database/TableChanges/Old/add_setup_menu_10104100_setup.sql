IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10104100 AND parent_menu_id = 10100000 AND product_category = 10000000)
BEGIN
	INSERT INTO setup_menu (
		function_id,
		window_name,
		display_name,
		hide_show,
		parent_menu_id,
		product_category,
		menu_order
	) 
	VALUES (
		10104100,
		'windowSetupUDFTemplate',
		'Maintain UDF Template',
		1,
		10100000,
		10000000,
		14
	)
END
ELSE
	PRINT 'This function ID already exists in menu.'