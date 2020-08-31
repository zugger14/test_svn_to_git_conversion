IF COL_LENGTH('application_license', 'concurrent_users') IS NULL
BEGIN
	ALTER TABLE application_license
	ADD concurrent_users INT
END
GO