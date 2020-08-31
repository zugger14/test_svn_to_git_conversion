USE adiha_cloud

IF COL_LENGTH('dbo.application_users','country') IS NULL
BEGIN
	ALTER TABLE application_users
	ADD country VARCHAR(50)
END