IF COL_LENGTH('admin_email_configuration', 'template_name') IS NULL
BEGIN
    ALTER TABLE admin_email_configuration ADD template_name VARCHAR(100)
END
GO

IF COL_LENGTH('admin_email_configuration', 'default_email') IS NULL
BEGIN
    ALTER TABLE admin_email_configuration ADD default_email CHAR(1)
END
GO