IF COL_LENGTH('counterparty_contract_address', 'negative_interest') IS NULL
BEGIN
	ALTER TABLE counterparty_contract_address 
	ADD negative_interest INT NULL
END
ELSE 
	PRINT('Column negative_interest already exists')	
GO