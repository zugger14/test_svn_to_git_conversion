IF COL_LENGTH('match_group_detail', 'scheduling_period') IS NOT NULL
BEGIN
    ALTER TABLE match_group_detail ALTER COLUMN scheduling_period VARCHAR(100)
END
GO

