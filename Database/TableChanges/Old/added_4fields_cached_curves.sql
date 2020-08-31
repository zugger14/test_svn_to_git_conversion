IF COL_LENGTH('cached_curves', 'create_user') IS NULL
BEGIN
    ALTER TABLE cached_curves ADD [create_user] VARCHAR(50) DEFAULT dbo.FNADBUser()
END

IF COL_LENGTH('cached_curves', '[create_ts]') IS NULL
BEGIN
    ALTER TABLE cached_curves ADD [create_ts] DATETIME DEFAULT GETDATE()
END

IF COL_LENGTH('cached_curves', '[update_user]') IS NULL
BEGIN
    ALTER TABLE cached_curves ADD [update_user] VARCHAR(50) NULL
END

IF COL_LENGTH('cached_curves', 'update_ts') IS NULL
BEGIN
    ALTER TABLE cached_curves ADD [update_ts] DATETIME NULL
END
