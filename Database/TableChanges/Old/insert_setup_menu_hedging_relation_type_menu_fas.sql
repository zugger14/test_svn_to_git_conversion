If Exists(SELECT 1 FROM setup_menu WHERE product_category = 13000000 AND display_name = 'Hedging Relationship Types Report' AND parent_menu_id = 10231997)
BEGIN	
	---deleting multiple menus
	DELETE FROM setup_menu WHERE display_name = 'Hedging Relationship Types Report'  AND function_id = 10232000 AND product_category = 13000000
END	
	
	
 IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE product_category = 13000000 AND display_name = 'Hedging Relationship Types Report' AND parent_menu_id = 10202200)
	---inserting new menu under reporting 
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
	VALUES (10232000, '', 'Hedging Relationship Types Report', '', 1, 10202200, 13000000, 1, 0)
	PRINT 'Hedging Relationship Types Report menu 10232000 INSERTED.'
	END
	ELSE
	BEGIN
		PRINT 'Hedging Strategies menu 10231997 already exists.'
	END
	
