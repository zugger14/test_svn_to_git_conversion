IF COL_LENGTH('application_license', 'total_read_only_users') IS NULL
BEGIN
    ALTER TABLE application_license ADD total_read_only_users INT
	PRINT 'Column application_license added in table total_read_only_users.'
END
ELSE
BEGIN
	PRINT 'Column application_license already exists in table total_read_only_users.'
END

IF COL_LENGTH('application_license', 'concurrent_read_only_users') IS NULL
BEGIN
    ALTER TABLE application_license ADD concurrent_read_only_users INT
	PRINT 'Column application_license added in table concurrent_read_only_users.'
END
ELSE
BEGIN
	PRINT 'Column application_license already exists in table concurrent_read_only_users.'
END