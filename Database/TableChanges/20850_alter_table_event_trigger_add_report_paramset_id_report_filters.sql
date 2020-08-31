IF COL_LENGTH('event_trigger','report_paramset_id') IS NULL
	ALTER TABLE event_trigger ADD report_paramset_id INT

IF COL_LENGTH('event_trigger','report_filters') IS NULL
	ALTER TABLE event_trigger ADD report_filters INT