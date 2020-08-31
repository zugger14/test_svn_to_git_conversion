IF COL_LENGTH(N'counterparty_credit_migration', 'currency') IS NULL
BEGIN
	ALTER TABLE counterparty_credit_migration 
		ALTER COLUMN currency INT

	PRINT 'Altered column currency.'
END