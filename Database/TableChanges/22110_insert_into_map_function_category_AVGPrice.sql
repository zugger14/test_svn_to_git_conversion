IF NOT EXISTS (SELECT 1 FROM map_function_category WHERE category_id = 27403 AND function_name = 'AVGPrice')
BEGIN
	INSERT INTO map_function_category (category_id, function_name, is_active, function_desc)
	VALUES (27403, 'AVGPrice', 1, 'This function is used to find average Month price')
END
GO