IF COL_LENGTH('counterparty_contract_address', 'threshold_provided') IS NULL
BEGIN
	ALTER TABLE counterparty_contract_address 
	ADD threshold_provided FLOAT NULL
END
ELSE 
	PRINT('Column threshold_provided already exists')	
GO


IF COL_LENGTH('counterparty_contract_address', 'threshold_received') IS NULL
BEGIN
	ALTER TABLE counterparty_contract_address 
	ADD threshold_received FLOAT NULL
END
ELSE 
	PRINT('Column threshold_received already exists')	
GO