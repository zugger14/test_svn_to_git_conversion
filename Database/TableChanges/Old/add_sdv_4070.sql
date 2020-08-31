IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE code = 'commodity_type' AND value_id = 4070)
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value(value_id, type_id, code, description)
	VALUES(4070, 4000, 'commodity_type', 'Commodity Type')
	SET IDENTITY_INSERT static_data_value OFF
END