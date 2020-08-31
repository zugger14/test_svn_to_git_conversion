IF COL_LENGTH('status_rule_activity', 'create_user') IS NULL
BEGIN
    ALTER TABLE status_rule_activity ADD [create_user] VARCHAR(50) DEFAULT dbo.FNADBUser()
END

IF COL_LENGTH('status_rule_activity', '[update_user]') IS NULL
BEGIN
    ALTER TABLE status_rule_activity ADD [update_user] VARCHAR(50) NULL
END

IF COL_LENGTH('status_rule_activity', 'update_ts') IS NULL
BEGIN
    ALTER TABLE status_rule_activity ADD [update_ts] DATETIME NULL
END
