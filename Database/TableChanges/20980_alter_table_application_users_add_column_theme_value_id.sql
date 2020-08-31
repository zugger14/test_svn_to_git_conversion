IF COL_LENGTH('application_users', 'theme_value_id') IS NULL
BEGIN
    ALTER TABLE application_users
	ADD theme_value_id INT
END