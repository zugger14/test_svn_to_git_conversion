IF COL_LENGTH('calendar_events', 'snoozed') IS NOT NULL
BEGIN
    ALTER TABLE calendar_events DROP COLUMN snoozed
	PRINT 'Column removed successfully.'
END
GO