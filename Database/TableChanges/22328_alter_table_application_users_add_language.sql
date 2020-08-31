IF COL_LENGTH('application_users', 'language') IS NULL
BEGIN
	ALTER TABLE application_users
	/**
	Columns 
	language: Holds language settings
	*/
	ADD [language] INT

	PRINT 'Column ''language'' is added.'
END
ELSE
BEGIN
	PRINT 'Column ''language'' already exists.'
END

GO