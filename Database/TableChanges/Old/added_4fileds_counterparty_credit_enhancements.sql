IF COL_LENGTH('counterparty_credit_enhancements', 'create_user') IS NULL
BEGIN
    ALTER TABLE counterparty_credit_enhancements ADD [create_user] VARCHAR(50) DEFAULT dbo.FNADBUser()
END

IF COL_LENGTH('counterparty_credit_enhancements', '[create_ts]') IS NULL
BEGIN
    ALTER TABLE counterparty_credit_enhancements ADD [create_ts] DATETIME DEFAULT GETDATE()
END

IF COL_LENGTH('counterparty_credit_enhancements', '[update_user]') IS NULL
BEGIN
    ALTER TABLE counterparty_credit_enhancements ADD [update_user] VARCHAR(50) NULL
END

IF COL_LENGTH('counterparty_credit_enhancements', 'update_ts') IS NULL
BEGIN
    ALTER TABLE counterparty_credit_enhancements ADD [update_ts] DATETIME NULL
END
