IF NOT EXISTS (SELECT 1 FROM map_function_category WHERE function_id = 879) 
BEGIN
	INSERT INTO map_function_category(category_id, function_id)
	VALUES(27408, 879)
END
ELSE
	PRINT 'Already Mapped'