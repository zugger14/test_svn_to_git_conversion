IF NOT EXISTS(SELECT 'X' FROM static_data_type where type_id=15100)
INSERT INTO static_data_type(type_id,type_name,internal,description) values ('15100','Index Group','0','Index Group')


SET IDENTITY_INSERT static_data_value ON

IF NOT EXISTS (SELECT 'X' FROM static_data_value WHERE value_id = 291515)
BEGIN
	INSERT INTO static_data_value(value_id,type_id,code,description) VALUES(291515, 15100,'Gas Index','Gas Index')
	PRINT '''Gas Index'' Added in ''static_data_value'' table.'
END

IF NOT EXISTS (SELECT 'X' FROM static_data_value WHERE value_id = 291516)
BEGIN
	INSERT INTO static_data_value(value_id,type_id,code,description) VALUES(291516, 15100,'Power Index','Power Index')
	PRINT '''Power Index'' Added in ''static_data_value'' table.'
END

SET IDENTITY_INSERT static_data_value OFF




