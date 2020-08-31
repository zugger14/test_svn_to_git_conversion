IF EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20007400 AND sm.product_category = 10000000)
BEGIN
	UPDATE setup_menu
	SET parent_menu_id = 10161399
	WHERE function_id = 20007400 AND product_category = 10000000
END