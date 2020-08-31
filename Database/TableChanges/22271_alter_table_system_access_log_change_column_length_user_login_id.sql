IF OBJECT_ID(N'system_access_log', N'U') IS NOT NULL AND COL_LENGTH('system_access_log', 'user_login_id') IS NOT NULL
BEGIN
    ALTER TABLE system_access_log ALTER COLUMN user_login_id VARCHAR(150)
END
GO