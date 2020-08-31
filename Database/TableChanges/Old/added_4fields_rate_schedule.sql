IF COL_LENGTH('rate_schedule', 'create_user') IS NULL
BEGIN
    ALTER TABLE rate_schedule ADD [create_user] VARCHAR(50) DEFAULT dbo.FNADBUser()
END

IF COL_LENGTH('rate_schedule', '[create_ts]') IS NULL
BEGIN
    ALTER TABLE rate_schedule ADD [create_ts] DATETIME DEFAULT GETDATE()
END

IF COL_LENGTH('rate_schedule', '[update_user]') IS NULL
BEGIN
    ALTER TABLE rate_schedule ADD [update_user] VARCHAR(50) NULL
END

IF COL_LENGTH('rate_schedule', 'update_ts') IS NULL
BEGIN
    ALTER TABLE rate_schedule ADD [update_ts] DATETIME NULL
END