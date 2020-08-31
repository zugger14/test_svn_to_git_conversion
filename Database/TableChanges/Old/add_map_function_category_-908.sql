IF NOT EXISTS (SELECT 1 FROM map_function_category WHERE function_id = -908)
BEGIN
	INSERT INTO map_function_category(category_id, function_id, is_active)
	VALUES (27400, -908, 1)
END