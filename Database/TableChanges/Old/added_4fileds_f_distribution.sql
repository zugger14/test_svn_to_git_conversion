IF COL_LENGTH('f_distribution', 'create_user') IS NULL
BEGIN
    ALTER TABLE f_distribution ADD [create_user] VARCHAR(50) DEFAULT dbo.FNADBUser()
END

IF COL_LENGTH('f_distribution', '[create_ts]') IS NULL
BEGIN
    ALTER TABLE f_distribution ADD [create_ts] DATETIME DEFAULT GETDATE()
END

IF COL_LENGTH('f_distribution', '[update_user]') IS NULL
BEGIN
    ALTER TABLE f_distribution ADD [update_user] VARCHAR(50) NULL
END

IF COL_LENGTH('f_distribution', 'update_ts') IS NULL
BEGIN
    ALTER TABLE f_distribution ADD [update_ts] DATETIME NULL
END


