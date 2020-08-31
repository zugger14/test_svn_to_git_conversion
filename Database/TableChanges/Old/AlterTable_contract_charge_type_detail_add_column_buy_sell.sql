IF COL_LENGTH('contract_charge_type_detail', 'buy_sell') IS NULL
BEGIN
	ALTER TABLE contract_charge_type_detail ADD buy_sell CHAR(1) NULL
END