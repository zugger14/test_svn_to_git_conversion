IF COL_LENGTH('application_functions', 'deny_privilege_to_read_only_user') IS NULL
BEGIN
    ALTER TABLE application_functions ADD deny_privilege_to_read_only_user BIT
	PRINT 'Column application_functions added in table deny_privilege_to_read_only_user.'
END
ELSE
BEGIN
	PRINT 'Column application_functions already exists in table deny_privilege_to_read_only_user.'
END