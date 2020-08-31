IF NOT EXISTS (SELECT 1 FROM static_data_type WHERE [type_name] = 'Payment Type')
BEGIN
	INSERT INTO static_data_type (type_id, type_name, internal, description)
	VALUES (32300, 'Payment Type', 0, 'Payment Type')                                                                                                                 
END