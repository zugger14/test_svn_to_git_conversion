IF EXISTS (SELECT 'menu' FROM setup_menu AS sm WHERE sm.display_name = 'Maintain Compliance Groups' AND sm.setup_menu_id = 299)
BEGIN 
	UPDATE setup_menu
	SET
		hide_show = 1,
		parent_menu_id = 10100000,
		product_category =10000000
	WHERE setup_menu_id = 299
END


