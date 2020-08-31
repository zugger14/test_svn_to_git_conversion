--Author: Tara Nath Subedi
--Issue: Adding new logic for activity import for conservis
IF NOT EXISTS (SELECT 'x' FROM static_data_value WHERE value_id=5463)
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value(value_id,type_id,code,description) VALUES(5463,5450,'Activity_Data_New','Activity Data New Logic')
	SET IDENTITY_INSERT static_data_value OFF
	PRINT '''Activity_Data_New'' Added in ''static_data_value'' table.'
END


