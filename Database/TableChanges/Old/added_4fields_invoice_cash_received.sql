IF COL_LENGTH('invoice_cash_received', 'create_user') IS NULL
BEGIN
    ALTER TABLE invoice_cash_received ADD [create_user] VARCHAR(50) DEFAULT dbo.FNADBUser()
END

IF COL_LENGTH('invoice_cash_received', '[create_ts]') IS NULL
BEGIN
    ALTER TABLE invoice_cash_received ADD [create_ts] DATETIME DEFAULT GETDATE()
END

IF COL_LENGTH('invoice_cash_received', '[update_user]') IS NULL
BEGIN
    ALTER TABLE invoice_cash_received ADD [update_user] VARCHAR(50) NULL
END

IF COL_LENGTH('invoice_cash_received', 'update_ts') IS NULL
BEGIN
    ALTER TABLE invoice_cash_received ADD [update_ts] DATETIME NULL
END