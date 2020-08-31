IF COL_LENGTH('event_trigger', 'manual_step') IS NULL
BEGIN
    ALTER TABLE event_trigger ADD manual_step CHAR(1)
END
GO