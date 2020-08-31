IF COL_LENGTH('counterparty_contract_address','credit') IS NULL
BEGIN
	ALTER TABLE counterparty_contract_address
	ADD credit VARCHAR(MAX) NULL
END