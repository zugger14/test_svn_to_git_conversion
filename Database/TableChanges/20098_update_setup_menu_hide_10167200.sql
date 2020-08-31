IF EXISTS (SELECT 1 FROM setup_menu AS sm WHERE function_id = 10167200 AND sm.product_category = 10000000)
BEGIN
	UPDATE setup_menu
	SET
		hide_show = 0
	WHERE function_id = 10167200 AND product_category = 10000000
		 
END