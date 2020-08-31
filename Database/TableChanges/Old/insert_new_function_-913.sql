--DELETE FROM static_data_value WHERE value_id = -913
IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE value_id = -913)
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value(value_id,type_id,code,description)
	SELECT -913,800,'ABS','Retuens Absolute Value'
	SET IDENTITY_INSERT static_data_value OFF
END




