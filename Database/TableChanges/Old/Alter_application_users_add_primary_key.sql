IF COL_LENGTH('application_users', 'application_users_id') IS NULL
BEGIN
	ALTER TABLE application_users ADD application_users_id INT IDENTITY(1, 1)
END