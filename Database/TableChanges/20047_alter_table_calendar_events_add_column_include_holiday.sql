IF COL_LENGTH('calendar_events', 'include_holiday') IS NULL
BEGIN
	ALTER TABLE calendar_events ADD include_holiday CHAR(1) NOT NULL DEFAULT 'n'
	PRINT 'Column include_holiday added successfully.'
END
GO