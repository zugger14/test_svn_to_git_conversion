IF COL_LENGTH('application_users', 'decimal_separator') IS NULL
BEGIN
	ALTER TABLE
	/**
		ADD column decimal_separator
	*/
	application_users ADD decimal_separator INT
END


IF COL_LENGTH('application_users', 'group_separator') IS NULL
BEGIN
	ALTER TABLE
	/**
		ADD column decimal_separator
	*/
	application_users ADD group_separator INT
END
