IF COL_LENGTH('application_ui_filter', 'role_id') IS NULL
BEGIN
    ALTER TABLE application_ui_filter ADD role_id INT REFERENCES application_security_role(role_id) NULL
END
GO