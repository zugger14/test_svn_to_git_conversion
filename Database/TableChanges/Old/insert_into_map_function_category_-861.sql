IF NOT EXISTS (SELECT 1 FROM map_function_category WHERE function_id = -861) 
BEGIN
	INSERT INTO map_function_category(category_id, function_id, is_active)
	VALUES(27403, -861, 1)
END
ELSE
	PRINT 'Already Mapped'