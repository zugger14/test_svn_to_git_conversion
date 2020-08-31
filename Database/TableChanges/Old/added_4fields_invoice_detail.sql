IF COL_LENGTH('invoice_detail', 'create_user') IS NULL
BEGIN
    ALTER TABLE invoice_detail ADD [create_user] VARCHAR(50) DEFAULT dbo.FNADBUser()
END

IF COL_LENGTH('invoice_detail', '[create_ts]') IS NULL
BEGIN
    ALTER TABLE invoice_detail ADD [create_ts] DATETIME DEFAULT GETDATE()
END

IF COL_LENGTH('invoice_detail', '[update_user]') IS NULL
BEGIN
    ALTER TABLE invoice_detail ADD [update_user] VARCHAR(50) NULL
END

IF COL_LENGTH('invoice_detail', 'update_ts') IS NULL
BEGIN
    ALTER TABLE invoice_detail ADD [update_ts] DATETIME NULL
END