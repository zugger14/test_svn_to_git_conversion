IF COL_LENGTH('wacog_group', 'frequency') IS NOT NULL
BEGIN
    ALTER TABLE wacog_group
	ALTER COLUMN frequency CHAR(1)
END
GO