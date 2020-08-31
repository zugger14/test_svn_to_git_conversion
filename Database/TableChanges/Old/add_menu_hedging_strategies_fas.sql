IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10231997 AND product_category = 13000000)
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
	VALUES (10231997, '', 'Hedging Strategies', '', 1, 13190000, 13000000, 50, 0)
	PRINT 'Hedging Strategies menu 10231997 INSERTED.'
	END
	ELSE
	BEGIN
		PRINT 'Hedging Strategies menu 10231997 already exists.'
	END
	