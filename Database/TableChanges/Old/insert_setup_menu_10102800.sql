IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10102800 AND parent_menu_id = 10101099 AND product_category = 10000000)
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
		10102800,
		'windowSetupProfile',
		'Setup Profile',
		1,
		10101099,
		10000000,
		6,
		0
	)
	PRINT 'Setup Profile inserted.'
END
ELSE
BEGIN
	PRINT 'Setup Profile already exists.'
END