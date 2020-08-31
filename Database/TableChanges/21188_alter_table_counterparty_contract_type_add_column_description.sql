IF COL_LENGTH('counterparty_contract_type', 'description') IS NULL
BEGIN
	ALTER TABLE counterparty_contract_type 
	ADD [description] VARCHAR(MAX) NULL
END
ELSE 
	PRINT('Column description already exists')	
GO

 