IF COL_LENGTH('application_users', 'account_status') IS NULL
BEGIN
    ALTER TABLE application_users ADD account_status CHAR(1)
	PRINT 'Column account_status added in table application_users.'
END
ELSE
BEGIN
	PRINT 'Column account_status already exists in table application_users.'
END