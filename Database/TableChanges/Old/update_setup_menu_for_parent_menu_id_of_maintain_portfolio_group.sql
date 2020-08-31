IF EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10183200)
BEGIN
	UPDATE sm1
	SET sm1.menu_order = CASE WHEN sm1.function_id = 10183200 THEN
							(SELECT sm2.menu_order FROM setup_menu sm2 WHERE sm2.function_id = 10181299 AND sm2.product_category = 10000000)
							ELSE sm1.menu_order + 1
	                     END
	   , sm1.parent_menu_id = CASE WHEN sm1.function_id = 10183200 THEN 10180000 ELSE sm1.parent_menu_id END
	FROM setup_menu sm1
	WHERE  sm1.product_category = 10000000 
			  AND sm1.function_id >= 10180000 AND sm1.function_id <= 10189999
			  AND sm1.parent_menu_id LIKE '1018____' 
			  AND sm1.menu_order >= (SELECT sm2.menu_order FROM setup_menu sm2 WHERE sm2.function_id = 10181299 AND sm2.product_category = 10000000)
			  AND sm1.menu_order <= (SELECT sm3.menu_order FROM setup_menu sm3 WHERE sm3.function_id = 10183200 AND sm3.product_category = 10000000) 

	PRINT 'update success'
END
ELSE
	PRINT 'No data with function ID: 10183200'