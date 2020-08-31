IF COL_LENGTH('wacog_group', 'location_id') IS NOT NULL
BEGIN
    ALTER TABLE wacog_group
	ALTER COLUMN location_id VARCHAR(MAX)
END
GO