IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 10166900 AND sm.product_category = 10000000)
BEGIN
	INSERT INTO setup_menu
	(
		-- setup_menu_id -- this column value is auto-generated
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
	VALUES
	(
		10166900,
		'windowShutInVolume',
		'Shut In Volume',
		'',
		1,
		10160000,
		10000000,
		123,
		1
	)
	
	PRINT 'Setup Menu 10166900 inserted.'
END
ELSE
BEGIN
	PRINT 'Setup Menu 10166900 already exist.'
END

