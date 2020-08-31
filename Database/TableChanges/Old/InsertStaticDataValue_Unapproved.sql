SET IDENTITY_INSERT static_data_value ON
GO

IF NOT EXISTS (SELECT 'x' FROM static_data_value WHERE value_id=478)
BEGIN
	INSERT INTO static_data_value(value_id,type_id,code,description) 
	SELECT 478,475,'Unapproved','Unapproved'
END
GO

SET IDENTITY_INSERT static_data_value OFF
GO