IF COL_LENGTH('application_users', 'user_type') IS NULL
BEGIN
    ALTER TABLE application_users ADD user_type INT
	PRINT 'Column user_type added in table application_users.'
END
ELSE
BEGIN
	PRINT 'Column user_type already exists in table application_users.'
END