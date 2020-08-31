IF COL_LENGTH('event_trigger','is_disable') IS NULL
	ALTER TABLE event_trigger ADD is_disable CHAR(1)