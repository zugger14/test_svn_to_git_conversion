IF EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 20007400 AND product_category = 10000000)
BEGIN
	UPDATE setup_menu
	SET display_name = 'Setup WACOG Group'
	WHERE function_id = 20007400 AND product_category = 10000000
END