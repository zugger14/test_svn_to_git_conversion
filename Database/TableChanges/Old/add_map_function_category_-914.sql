IF NOT EXISTS (SELECT 1 FROM map_function_category WHERE function_id = -914 AND category_id = 27403)
BEGIN
	INSERT INTO map_function_category(category_id, function_id, is_active)
	VALUES (27403, -914, 1)
	PRINT 'Function Mapped to Price Categrory'
END