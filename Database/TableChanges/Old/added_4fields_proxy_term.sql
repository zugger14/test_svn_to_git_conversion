IF COL_LENGTH('proxy_term', 'create_user') IS NULL
BEGIN
    ALTER TABLE proxy_term ADD [create_user] VARCHAR(50) DEFAULT dbo.FNADBUser()
END

IF COL_LENGTH('proxy_term', '[create_ts]') IS NULL
BEGIN
    ALTER TABLE proxy_term ADD [create_ts] DATETIME DEFAULT GETDATE()
END

IF COL_LENGTH('proxy_term', '[update_user]') IS NULL
BEGIN
    ALTER TABLE proxy_term ADD [update_user] VARCHAR(50) NULL
END

IF COL_LENGTH('proxy_term', 'update_ts') IS NULL
BEGIN
    ALTER TABLE proxy_term ADD [update_ts] DATETIME NULL
END