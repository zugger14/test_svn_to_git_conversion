IF COL_LENGTH('broker_fees', 'create_user') IS NULL
BEGIN
    ALTER TABLE broker_fees ADD [create_user] VARCHAR(50) DEFAULT dbo.FNADBUser()
END

IF COL_LENGTH('broker_fees', '[create_ts]') IS NULL
BEGIN
    ALTER TABLE broker_fees ADD [create_ts] DATETIME DEFAULT GETDATE()
END

IF COL_LENGTH('broker_fees', '[update_user]') IS NULL
BEGIN
    ALTER TABLE broker_fees ADD [update_user] VARCHAR(50) NULL
END

IF COL_LENGTH('broker_fees', 'update_ts') IS NULL
BEGIN
    ALTER TABLE broker_fees ADD [update_ts] DATETIME NULL
END
