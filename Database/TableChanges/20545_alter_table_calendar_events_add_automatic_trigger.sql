IF COL_LENGTH('calendar_events', 'automatic_trigger') IS NULL
BEGIN
    ALTER TABLE calendar_events ADD automatic_trigger CHAR(1)
END
GO