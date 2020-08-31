IF COL_LENGTH('counterparty_limits', '[create_user]') IS NULL
BEGIN
    ALTER TABLE counterparty_limits ADD [create_user] VARCHAR(50) DEFAULT dbo.FNADBUser()
END

IF COL_LENGTH('counterparty_limits', '[create_ts]') IS NULL
BEGIN
    ALTER TABLE counterparty_limits ADD [create_ts] DATETIME DEFAULT GETDATE()
END

IF COL_LENGTH('counterparty_limits', '[update_user]') IS NULL
BEGIN
    ALTER TABLE counterparty_limits ADD [update_user] VARCHAR(50) NULL
END

IF COL_LENGTH('counterparty_limits', '[update_ts]') IS NULL
BEGIN
    ALTER TABLE counterparty_limits ADD [update_ts] DATETIME NULL
END