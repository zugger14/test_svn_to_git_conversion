IF COL_LENGTH('admin_email_configuration', 'cust_id') IS NULL
BEGIN
    ALTER TABLE admin_email_configuration ADD cust_id INT NULL 
END
GO
