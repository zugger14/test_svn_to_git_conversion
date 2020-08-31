SET IDENTITY_INSERT static_data_value ON 
GO 
IF NOT EXISTS(SELECT 'x' FROM static_data_value WHERE value_id=409)
INSERT INTO static_data_value (value_id,type_id,code,description)
VALUES(409,400,'Load Trans','Load Trans')
GO
SET IDENTITY_INSERT static_data_value OFF
GO 