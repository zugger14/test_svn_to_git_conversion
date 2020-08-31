IF COL_LENGTH('module_events','event_id') IS NOT NULL
	ALTER TABLE module_events ALTER COLUMN event_id VARCHAR(2000)