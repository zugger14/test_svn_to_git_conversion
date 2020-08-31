IF NOT EXISTS (SELECT 1 FROM sys.[columns] c WHERE c.name = 'primary_account' AND OBJECT_ID = OBJECT_ID(N'counterparty_bank_info'))
BEGIN
	ALTER TABLE counterparty_bank_info ADD primary_account CHAR(1)
END
ELSE 
	PRINT 'primary_account column already exists.'