IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'contract_charge_type_detail' AND COLUMN_NAME = 'group1')
BEGIN
	ALTER TABLE contract_charge_type_detail ADD  group1 INT NULL
END

GO

IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'contract_charge_type_detail' AND COLUMN_NAME = 'group2')
BEGIN
	ALTER TABLE contract_charge_type_detail ADD  group2 INT NULL
END

GO

IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'contract_charge_type_detail' AND COLUMN_NAME = 'group3')
BEGIN
	ALTER TABLE contract_charge_type_detail ADD  group3 INT NULL
END

GO

IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'contract_charge_type_detail' AND COLUMN_NAME = 'group4')
BEGIN
	ALTER TABLE contract_charge_type_detail ADD  group4 INT NULL
END

GO

IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'contract_charge_type_detail' AND COLUMN_NAME = 'leg')
BEGIN
	ALTER TABLE contract_charge_type_detail ADD  leg INT NULL
END

GO