
IF NOT EXISTS(SELECT 'x' FROM static_data_value WHERE value_id=37)
BEGIN
SET IDENTITY_INSERT static_data_value ON
INSERT INTO static_data_value(value_id,type_id,code,description) VALUES(37,25,'Counterparty','Counterparty')
SET IDENTITY_INSERT static_data_value OFF
END
