IF EXISTS (select 1 from static_data_type where type_id = 42000)
BEGIN
	UPDATE static_data_type 
	SET [type_name] = 'Documents Type',
		[description] = 'Documents Type',
		internal = 1
	WHERE [type_id] = 42000
END