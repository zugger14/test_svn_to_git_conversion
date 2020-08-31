IF COL_LENGTH(N'wacog_group', N'curve_id') IS NOT NULL
BEGIN
	ALTER TABLE wacog_group ALTER COLUMN curve_id VARCHAR(MAX)
END