IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 10241100 AND sm.product_category = 10000000)
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
		10241100,
		'windowApplyCash',
		'Apply Cash',
		1,
		10220000,
		10000000,
		111,
		0
	)
	
	PRINT 'setup menu with function id 10241100 is inserted.'
END
ELSE
BEGIN
	PRINT 'setup menu with function id 10241100 already exist.'
END