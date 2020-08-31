IF EXISTS (SELECT * FROM setup_menu WHERE function_id = 10131300 AND product_category = 10000000)
BEGIN
	UPDATE setup_menu
	SET display_name = 'Import Data'
	WHERE function_id = 10131300 AND product_category = 10000000
END