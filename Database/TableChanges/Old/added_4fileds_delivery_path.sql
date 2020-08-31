IF COL_LENGTH('delivery_path', '[create_user]') IS NULL
BEGIN
    ALTER TABLE delivery_path ADD [create_user] VARCHAR(50) DEFAULT dbo.FNADBUser()
END

IF COL_LENGTH('delivery_path', '[create_ts]') IS NULL
BEGIN
    ALTER TABLE delivery_path ADD [create_ts] DATETIME DEFAULT GETDATE()
END

IF COL_LENGTH('delivery_path', '[update_user]') IS NULL
BEGIN
    ALTER TABLE delivery_path ADD [update_user] VARCHAR(50) NULL
END

IF COL_LENGTH('delivery_path', '[update_ts]') IS NULL
BEGIN
    ALTER TABLE delivery_path ADD [update_ts] DATETIME NULL
END