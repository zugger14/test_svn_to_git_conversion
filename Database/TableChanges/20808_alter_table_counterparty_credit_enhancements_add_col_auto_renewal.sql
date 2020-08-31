IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'auto_renewal' and Object_ID = Object_ID(N'counterparty_credit_enhancements'))
BEGIN
	ALTER TABLE counterparty_credit_enhancements ADD auto_renewal char(1)
END
ELSE
PRINT 'Column auto_renewal already exists'