IF COL_LENGTH('counterparty_credit_info', 'create_user') IS NULL
BEGIN
    ALTER TABLE counterparty_credit_info ADD [create_user] VARCHAR(50) DEFAULT dbo.FNADBUser()
END

IF COL_LENGTH('counterparty_credit_info', '[create_ts]') IS NULL
BEGIN
    ALTER TABLE counterparty_credit_info ADD [create_ts]  DATETIME DEFAULT GETDATE()
END

IF COL_LENGTH('counterparty_credit_info', '[update_user]') IS NULL
BEGIN
    ALTER TABLE counterparty_credit_info ADD [update_user] VARCHAR(50) NULL
END

IF COL_LENGTH('counterparty_credit_info', 'update_ts') IS NULL
BEGIN
    ALTER TABLE counterparty_credit_info ADD [update_ts] DATETIME NULL
END