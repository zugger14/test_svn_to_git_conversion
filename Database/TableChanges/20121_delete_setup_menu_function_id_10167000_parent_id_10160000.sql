IF EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10167000 AND parent_menu_id = 10160000 AND product_category = 10000000)
BEGIN
	DELETE FROM setup_menu WHERE function_id = 10167000 AND parent_menu_id = 10160000 AND product_category = 10000000
END