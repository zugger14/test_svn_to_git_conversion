
IF COL_LENGTH('deal_lock_setup', '[update_user]') IS NULL
BEGIN
    ALTER TABLE deal_lock_setup ADD [update_user] VARCHAR(50) NULL
END

IF COL_LENGTH('deal_lock_setup', 'update_ts') IS NULL
BEGIN
    ALTER TABLE deal_lock_setup ADD [update_ts] DATETIME NULL
END