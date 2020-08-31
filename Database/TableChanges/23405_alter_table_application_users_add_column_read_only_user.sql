IF COL_LENGTH('application_users', 'read_only_user') IS NULL
BEGIN
    ALTER TABLE application_users ADD read_only_user CHAR(1)
	PRINT 'Column read_only_user added in table application_users.'
END
ELSE
BEGIN
	PRINT 'Column read_only_user already exists in table application_users.'
END