IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10183499 AND parent_menu_id = 10180000 AND product_category = 10000000)
BEGIN
	INSERT INTO setup_menu 
	(
		function_id,
		window_name,
		display_name,
		hide_show,
		parent_menu_id,
		product_category,
		menu_order,
		menu_type
	)
	VALUES
	(
		10183499,
		NULL,
		'Run What-If',
		1,
		10180000,
		10000000,
		25,
		1
	)
	PRINT 'Menu inserted successfully.'
END
ELSE
BEGIN
	PRINT 'Menu already exist.'
END
