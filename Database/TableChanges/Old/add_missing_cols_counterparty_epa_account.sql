IF COL_LENGTH('counterparty_epa_account', 'create_ts') IS NULL
BEGIN
	ALTER TABLE counterparty_epa_account ADD [create_ts] DATETIME DEFAULT GETDATE()
END
GO

IF COL_LENGTH('counterparty_epa_account', 'create_user') IS NULL
BEGIN
	ALTER TABLE counterparty_epa_account ADD [create_user] VARCHAR(150) DEFAULT dbo.FNADBuser()
END
GO


IF COL_LENGTH('counterparty_epa_account', 'update_ts') IS NULL
BEGIN
	ALTER TABLE counterparty_epa_account ADD [update_ts] DATETIME DEFAULT GETDATE()
END
GO


IF COL_LENGTH('counterparty_epa_account', 'update_user') IS NULL
BEGIN
	ALTER TABLE counterparty_epa_account ADD [update_user] VARCHAR(150) 
END
GO

