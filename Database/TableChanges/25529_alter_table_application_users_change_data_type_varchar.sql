IF COL_LENGTH('application_users', 'decimal_separator') IS NOT NULL
BEGIN
	ALTER TABLE application_users 
	/**
	Columns 
	decimal_separator: Change data type to NCHAR
	*/
	ALTER COLUMN decimal_separator VARCHAR(10);
END


IF COL_LENGTH('application_users', 'group_separator') IS NOT NULL
BEGIN
	ALTER TABLE application_users 
	/**
	Columns 
	group_separator: Change data type to NCHAR
	*/
	ALTER COLUMN group_separator VARCHAR(10);
END
