

IF COL_LENGTH('match_group_header', 'container_number') IS NULL
BEGIN
    ALTER TABLE match_group_header ADD container_number VARCHAR(MAX)
END
GO

