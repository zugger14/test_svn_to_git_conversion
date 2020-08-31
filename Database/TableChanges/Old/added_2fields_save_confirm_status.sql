IF COL_LENGTH('save_confirm_status', '[update_user]') IS NULL
BEGIN
    ALTER TABLE save_confirm_status ADD [update_user] VARCHAR(50) NULL
END

IF COL_LENGTH('save_confirm_status', 'update_ts') IS NULL
BEGIN
    ALTER TABLE save_confirm_status ADD [update_ts] DATETIME NULL
END