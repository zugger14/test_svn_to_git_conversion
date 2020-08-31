IF EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10181800  AND product_category = 10000000)
BEGIN
	UPDATE setup_menu SET window_name = 'windowCalImpVolatility'
	WHERE function_id = 10181800  AND parent_menu_id = 10000000
END