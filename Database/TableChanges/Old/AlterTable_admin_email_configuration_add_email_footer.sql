IF COL_LENGTH('admin_email_configuration', 'email_footer') IS NULL
BEGIN
    ALTER TABLE admin_email_configuration ADD email_footer VARCHAR(8000)
END
GO