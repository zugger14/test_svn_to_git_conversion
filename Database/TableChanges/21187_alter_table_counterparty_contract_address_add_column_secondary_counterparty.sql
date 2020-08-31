IF COL_LENGTH('counterparty_contract_address', 'secondary_counterparty') IS NULL
BEGIN
	ALTER TABLE counterparty_contract_address 
	ADD secondary_counterparty INT NULL
END
ELSE 
	PRINT('Column secondary_counterparty already exists')	
GO