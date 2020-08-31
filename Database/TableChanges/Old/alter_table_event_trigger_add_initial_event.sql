IF COL_LENGTH('event_trigger', 'initial_event') IS NULL
BEGIN
    ALTER TABLE event_trigger ADD initial_event CHAR(1)
END
GO