IF NOT EXISTS(SELECT * FROM static_data_type WHERE type_id in(15500))
	INSERT INTO static_data_type(type_id, type_name, internal, description)
	SELECT 15500, 'Module Type', 1, 'Module Type'
GO
SET IDENTITY_INSERT static_data_value ON
GO
IF NOT EXISTS(SELECT * FROM static_data_value WHERE value_id in(15500))
	INSERT INTO static_data_value(value_id, type_id, code, description)
	SELECT 15500, 15500, 'Fas', 'Fas'
GO