IF EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 20007900 AND product_category = 14000000)
BEGIN
	UPDATE setup_menu
	SET display_name = 'Match Environmental Product'
	WHERE [function_id] = 20007900
	AND [product_category]= 14000000
	PRINT 'Updated Setup Menu.'   
END