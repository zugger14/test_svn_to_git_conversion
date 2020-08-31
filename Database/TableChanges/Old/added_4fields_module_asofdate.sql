IF COL_LENGTH('module_asofdate', 'create_user') IS NULL
BEGIN
    ALTER TABLE module_asofdate ADD [create_user] VARCHAR(50) DEFAULT dbo.FNADBUser()
END

IF COL_LENGTH('module_asofdate', '[create_ts]') IS NULL
BEGIN
    ALTER TABLE module_asofdate ADD [create_ts] DATETIME DEFAULT GETDATE()
END

IF COL_LENGTH('module_asofdate', '[update_user]') IS NULL
BEGIN
    ALTER TABLE module_asofdate ADD [update_user] VARCHAR(50) NULL
END

IF COL_LENGTH('module_asofdate', 'update_ts') IS NULL
BEGIN
    ALTER TABLE module_asofdate ADD [update_ts] DATETIME NULL
END