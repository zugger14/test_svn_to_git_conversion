IF COL_LENGTH('dbo.connection_string', 'system_defined_password') IS NULL
BEGIN
	ALTER TABLE connection_string
	ADD system_defined_password VARCHAR(50)
END




