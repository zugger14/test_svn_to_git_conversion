IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 1289 AND parent_menu_id = 10183499 AND product_category = 10000000)
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
		10183400,
		'windowSetupWhatIfCriteria',
		'Setup What if Criteria',
		1,
		10183499,
		10000000,
		27,
		0
	)
	PRINT 'Menu inserted successfully.'
END
ELSE
BEGIN
	PRINT 'Menu already exist.'
END