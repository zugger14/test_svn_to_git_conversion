IF COL_LENGTH('application_functions', 'is_sensitive') IS NULL
BEGIN
	ALTER TABLE application_functions
	ADD is_sensitive BIT
END