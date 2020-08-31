IF COL_LENGTH('save_confirm_detail', 'create_user') IS NULL
BEGIN
    ALTER TABLE save_confirm_detail ADD [create_user] VARCHAR(50) DEFAULT dbo.FNADBUser()
END

IF COL_LENGTH('save_confirm_detail', '[create_ts]') IS NULL
BEGIN
    ALTER TABLE save_confirm_detail ADD [create_ts] DATETIME DEFAULT GETDATE()
END

IF COL_LENGTH('save_confirm_detail', '[update_user]') IS NULL
BEGIN
    ALTER TABLE save_confirm_detail ADD [update_user] VARCHAR(50) NULL
END

IF COL_LENGTH('save_confirm_detail', 'update_ts') IS NULL
BEGIN
    ALTER TABLE save_confirm_detail ADD [update_ts] DATETIME NULL
END

IF COL_LENGTH('save_confirm_detail', 'save_confirm_id') IS NULL
BEGIN
    ALTER TABLE save_confirm_detail ADD save_confirm_id INT IDENTITY(1,1)
END

