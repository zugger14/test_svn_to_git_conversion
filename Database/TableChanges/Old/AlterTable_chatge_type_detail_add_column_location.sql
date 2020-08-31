IF COL_LENGTH('contract_charge_type_detail', 'location') IS NULL
BEGIN
	ALTER TABLE contract_charge_type_detail ADD location INT NULL
END