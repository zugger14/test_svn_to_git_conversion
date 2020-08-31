IF COL_LENGTH('application_users', 'theme_value_id') IS NOT NULL
BEGIN
	ALTER TABLE application_users
	ALTER COLUMN theme_value_id VARCHAR(100)
END
