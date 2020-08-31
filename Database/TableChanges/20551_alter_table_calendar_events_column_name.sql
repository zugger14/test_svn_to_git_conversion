IF COL_LENGTH('calendar_events', 'name') IS NOT NULL
BEGIN
    ALTER TABLE calendar_events ALTER COLUMN name VARCHAR(500)
END
GO