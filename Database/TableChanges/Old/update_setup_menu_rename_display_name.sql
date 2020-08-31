IF EXISTS (SELECT 1 FROM setup_menu  WHERE function_id = 10101099 AND parent_menu_id = 10100000 AND product_category = 13000000)
BEGIN 
	UPDATE setup_menu
	SET display_name = 'Reference Data'
	WHERE function_id = 10101099 AND parent_menu_id = 10100000 AND product_category = 13000000
END
