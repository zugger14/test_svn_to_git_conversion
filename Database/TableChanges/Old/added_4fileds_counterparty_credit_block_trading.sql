IF COL_LENGTH('counterparty_credit_block_trading', 'create_user') IS NULL
BEGIN
    ALTER TABLE counterparty_credit_block_trading ADD [create_user] VARCHAR(50) DEFAULT dbo.FNADBUser()
END

IF COL_LENGTH('counterparty_credit_block_trading', '[create_ts]') IS NULL
BEGIN
    ALTER TABLE counterparty_credit_block_trading ADD [create_ts] DATETIME DEFAULT GETDATE()
END

IF COL_LENGTH('counterparty_credit_block_trading', '[update_user]') IS NULL
BEGIN
    ALTER TABLE counterparty_credit_block_trading ADD [update_user] VARCHAR(50) NULL
END

IF COL_LENGTH('counterparty_credit_block_trading', 'update_ts') IS NULL
BEGIN
    ALTER TABLE counterparty_credit_block_trading ADD [update_ts] DATETIME NULL
END