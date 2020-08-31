IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE code = 'commodity_attribute' AND value_id = 4071)
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value(value_id, type_id, code, description)
	VALUES(4071, 4000, 'commodity_attribute', 'Commodity Attribute')
	SET IDENTITY_INSERT static_data_value OFF
END