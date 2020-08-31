IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE value_id = 2)
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (2, 1, 'Data Import Integration Group', 'Data Import Integration Group', '', 'farrms_admin', GETDATE())
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE
BEGIN
	UPDATE static_data_value 
	SET code = 'Data Import Integration Group'
	WHERE value_id = 2
END