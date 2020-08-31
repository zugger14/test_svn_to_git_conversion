IF EXISTS(SELECT 1 FROM setup_menu WHERE function_id=10181000 AND product_category IN (10000000,10000010) AND parent_menu_id NOT IN (10180000))
BEGIN
	DELETE FROM setup_menu WHERE function_id=10181000 AND product_category IN (10000000,10000010) AND parent_menu_id NOT IN (10180000)
END