IF COL_LENGTH('calendar_events','scheduled_as_of_date') IS NULL
	ALTER TABLE calendar_events ADD scheduled_as_of_date DATETIME
GO