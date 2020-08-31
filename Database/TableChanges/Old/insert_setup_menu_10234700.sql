IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10234700 AND parent_menu_id = 10130000 AND product_category = 10000000)
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
		10234700,
		'windowMaintainDealTransfer',
		'Maintain Deal Transfer',
		1,
		10130000,
		10000000,
		54,
		0
	)

	PRINT 'Maintain Deal Transfer inserted.'
END
ELSE 
BEGIN
	PRINT 'Maintain Deal Transfer menu already exists.'
END

