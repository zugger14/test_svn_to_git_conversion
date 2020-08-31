IF COL_LENGTH('inventory_account_type_group', 'create_user') IS NULL
BEGIN
    ALTER TABLE inventory_account_type_group ADD [create_user] VARCHAR(50) DEFAULT dbo.FNADBUser()
END

IF COL_LENGTH('inventory_account_type_group', '[create_ts]') IS NULL
BEGIN
    ALTER TABLE inventory_account_type_group ADD [create_ts] DATETIME DEFAULT GETDATE()
END

IF COL_LENGTH('inventory_account_type_group', '[update_user]') IS NULL
BEGIN
    ALTER TABLE inventory_account_type_group ADD [update_user] VARCHAR(50) NULL
END

IF COL_LENGTH('inventory_account_type_group', 'update_ts') IS NULL
BEGIN
    ALTER TABLE inventory_account_type_group ADD [update_ts] DATETIME NULL
END