IF COL_LENGTH('counterparty_contract_address', 'prepay') IS NULL
BEGIN
	ALTER TABLE counterparty_contract_address
	ADD prepay CHAR(1) NULL
END