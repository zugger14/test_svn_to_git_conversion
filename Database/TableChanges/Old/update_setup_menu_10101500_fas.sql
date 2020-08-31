IF EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10101500 AND product_category = 13000000)
BEGIN
	UPDATE setup_menu
	SET
	display_name = 'Setup Netting Group'
	WHERE function_id = 10101500 AND product_category = 13000000
END