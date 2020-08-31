IF COL_LENGTH('counterparty_contract_address', 'no_of_days') IS NULL
BEGIN
	ALTER TABLE counterparty_contract_address 
	ADD no_of_days INT NULL
END
ELSE 
	PRINT('Column no_of_days already exists')	
GO