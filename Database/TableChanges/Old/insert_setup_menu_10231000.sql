IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10231000 AND parent_menu_id = 10100000 AND product_category = 10000000)
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
		10231000,
		'windowSetupInventoryGLAccount',
		'Setup Inventory GL Account',
		1,
		10100000,
		10000000,
		40,
		0
	)

	PRINT 'Setup Inventory GL Account inserted.'
END
ELSE
BEGIN
	PRINT 'Setup Inventory GL Account menu already exist.'
END