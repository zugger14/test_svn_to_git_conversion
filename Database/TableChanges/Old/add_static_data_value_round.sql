SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value where value_id =  -908)
BEGIN
	insert into static_data_value(value_id, type_id, code, description)
	select -908,800,'round','round'
END
SET IDENTITY_INSERT static_data_value OFF