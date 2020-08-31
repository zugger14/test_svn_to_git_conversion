IF COL_LENGTH('application_license', 'concurrent_user') IS NOT NULL
BEGIN
	EXEC sp_rename 'dbo.application_license.concurrent_user', 'total_users', 'COLUMN'
END