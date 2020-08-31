
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5620)
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value(value_id, type_id, code, description)
	SELECT '-5620', 5500, 'PRP Code Power', 'PRP Code Power'
	SET IDENTITY_INSERT static_data_value OFF
END

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5621)
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value(value_id, type_id, code, description)
	SELECT '-5621', 5500, 'PRP Code Gas', 'PRP Code Gas'
	SET IDENTITY_INSERT static_data_value OFF
END

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5622)
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value(value_id, type_id, code, description)
	SELECT '-5622', 5500, 'EAN Code Power', 'EAN Code Power'
	SET IDENTITY_INSERT static_data_value OFF
END

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5623)
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value(value_id, type_id, code, description)
	SELECT '-5623', 5500, 'EAN Code Gas', 'EAN Code Gas'
	SET IDENTITY_INSERT static_data_value OFF
END
