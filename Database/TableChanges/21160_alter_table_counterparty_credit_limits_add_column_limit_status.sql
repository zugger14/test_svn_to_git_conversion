IF COL_LENGTH('counterparty_credit_limits', 'limit_status') IS NULL
BEGIN
	ALTER TABLE counterparty_credit_limits 
	ADD limit_status INT NULL
END
ELSE 
	PRINT('Column limit_status already exists')	
GO