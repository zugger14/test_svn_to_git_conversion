IF NOT EXISTS (SELECT 'X' FROM static_data_type WHERE TYPE_ID = 17100)
BEGIN
	INSERT INTO  static_data_type (type_id, type_name, internal, description) VALUES (17100, 'Cashflow-Earnings', 0, 'Cashflow-Earnings')
END

SET IDENTITY_INSERT static_data_value ON

IF NOT EXISTS (SELECT 'X' FROM static_data_value WHERE value_id = 17101)
BEGIN
	INSERT INTO static_data_value(value_id,type_id,code,description) VALUES(17101, 17100,'CashFlow','CashFlow')
	PRINT '''CashFlow'' Added in ''static_data_value'' table.'
END

IF NOT EXISTS (SELECT 'X' FROM static_data_value WHERE value_id = 17102)
BEGIN
	INSERT INTO static_data_value(value_id,type_id,code,description) VALUES(17102, 17100,'Earnings','Earnings')
	PRINT '''Earnings'' Added in ''static_data_value'' table.'
END

SET IDENTITY_INSERT static_data_value OFF
		