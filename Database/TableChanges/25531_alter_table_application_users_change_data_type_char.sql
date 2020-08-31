IF COL_LENGTH('application_users', 'decimal_separator') IS NOT NULL
BEGIN
	ALTER TABLE application_users 
	/**
	Columns 
	decimal_separator: Change data type to NVARCHAR
	*/
	ALTER COLUMN decimal_separator NVARCHAR(1);
END


IF COL_LENGTH('application_users', 'group_separator') IS NOT NULL
BEGIN
	ALTER TABLE application_users 
	/**
	Columns 
	group_separator: Change data type to NVARCHAR
	*/
	ALTER COLUMN group_separator NVARCHAR(1);
END

