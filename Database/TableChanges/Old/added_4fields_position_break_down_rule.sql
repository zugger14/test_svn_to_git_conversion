IF COL_LENGTH('position_break_down_rule', 'create_user') IS NULL
BEGIN
    ALTER TABLE position_break_down_rule ADD [create_user] VARCHAR(50) DEFAULT dbo.FNADBUser()
END

IF COL_LENGTH('position_break_down_rule', '[create_ts]') IS NULL
BEGIN
    ALTER TABLE position_break_down_rule ADD [create_ts] DATETIME DEFAULT GETDATE()
END

IF COL_LENGTH('position_break_down_rule', '[update_user]') IS NULL
BEGIN
    ALTER TABLE position_break_down_rule ADD [update_user] VARCHAR(50) NULL
END

IF COL_LENGTH('position_break_down_rule', 'update_ts') IS NULL
BEGIN
    ALTER TABLE position_break_down_rule ADD [update_ts] DATETIME NULL
END