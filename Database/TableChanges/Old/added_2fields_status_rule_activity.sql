IF COL_LENGTH('status_rule_activity', 'create_user') IS NULL
BEGIN
    ALTER TABLE status_rule_activity ADD [create_user] VARCHAR(50) DEFAULT dbo.FNADBUser()
END

IF COL_LENGTH('status_rule_activity', '[create_ts]') IS NULL
BEGIN
    ALTER TABLE status_rule_activity ADD [create_ts] DATETIME DEFAULT GETDATE()
END
