IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10132000 AND product_category = 13000000)
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
	VALUES (10132000, 'windowMaintainDeals', 'Create and View Deals New', '', 1, 10131099, 13000000, 50, 0)
	PRINT 'Create and View Deals New menu 10132000 INSERTED.'
	END
	ELSE
	BEGIN
		PRINT 'Create and View Deals New menu 10132000 already exists.'
	END
	
