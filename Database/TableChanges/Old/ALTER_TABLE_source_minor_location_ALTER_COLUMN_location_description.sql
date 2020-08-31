IF COL_LENGTH('source_minor_location', 'location_description') IS NOT NULL
	ALTER TABLE source_minor_location ALTER COLUMN location_description VARCHAR(500)
GO  