IF EXISTS (SELECT 1 FROM static_data_type WHERE [type_id] = 15000)
BEGIN
	UPDATE static_data_type
	SET
		TYPE_NAME = 'Tier'
	WHERE [type_id] = 15000	
END 