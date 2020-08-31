IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE value_id = 3 AND code = 'Email Group') 
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	SELECT 3, 1, 'Email Group',	'Email Group'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE
	PRINT 'Data already exists.' 