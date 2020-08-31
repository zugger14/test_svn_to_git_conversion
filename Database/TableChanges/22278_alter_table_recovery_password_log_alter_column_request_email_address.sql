IF OBJECT_ID(N'recovery_password_log', N'U') IS NOT NULL AND COL_LENGTH('recovery_password_log', 'request_email_address') IS NOT NULL
BEGIN
    ALTER TABLE recovery_password_log ALTER COLUMN request_email_address VARCHAR(150)
END
GO