IF COL_LENGTH('meter_id_channel', 'create_user') IS NULL
BEGIN
    ALTER TABLE meter_id_channel ADD [create_user] VARCHAR(50) DEFAULT dbo.FNADBUser()
END

IF COL_LENGTH('meter_id_channel', '[create_ts]') IS NULL
BEGIN
    ALTER TABLE meter_id_channel ADD [create_ts] DATETIME DEFAULT GETDATE()
END

IF COL_LENGTH('meter_id_channel', '[update_user]') IS NULL
BEGIN
    ALTER TABLE meter_id_channel ADD [update_user] VARCHAR(50) NULL
END

IF COL_LENGTH('meter_id_channel', 'update_ts') IS NULL
BEGIN
    ALTER TABLE meter_id_channel ADD [update_ts] DATETIME NULL
END