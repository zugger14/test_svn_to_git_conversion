IF COL_LENGTH('calendar_events','module_id') IS NULL 
	ALTER TABLE calendar_events ADD module_id INT
GO
	

IF COL_LENGTH('calendar_events','event_message_id') IS NULL 
	ALTER TABLE calendar_events ADD event_message_id INT
GO