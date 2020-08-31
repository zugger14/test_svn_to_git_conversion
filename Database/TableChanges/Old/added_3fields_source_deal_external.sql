IF COL_LENGTH('source_deal_external', 'create_user') IS NULL
BEGIN
    ALTER TABLE source_deal_external ADD [create_user] VARCHAR(50) DEFAULT dbo.FNADBUser()
END

IF COL_LENGTH('source_deal_external', '[update_user]') IS NULL
BEGIN
    ALTER TABLE source_deal_external ADD [update_user] VARCHAR(50) NULL
END

IF COL_LENGTH('source_deal_external', 'update_ts') IS NULL
BEGIN
    ALTER TABLE source_deal_external ADD [update_ts] DATETIME NULL
END