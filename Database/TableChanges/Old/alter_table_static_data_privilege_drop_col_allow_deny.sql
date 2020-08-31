IF COL_LENGTH('static_data_privilege', 'allow_deny') IS NOT NULL
BEGIN
    ALTER TABLE static_data_privilege DROP COLUMN  allow_deny
END
GO

