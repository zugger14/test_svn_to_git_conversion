IF COL_LENGTH(N'counterparty_credit_migration', 'currency') IS NULL
BEGIN
	ALTER TABLE counterparty_credit_migration 
		ADD currency FLOAT

	PRINT 'Added column currency.'
END