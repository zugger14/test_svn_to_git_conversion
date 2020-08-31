IF COL_LENGTH('system_access_log', 'cookie_hash') = 100
BEGIN
	ALTER TABLE system_access_log
	ALTER COLUMN cookie_hash VARCHAR(300)
END
GO