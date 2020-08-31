
IF COL_LENGTH('source_minor_location', 'conversion_name') IS NOT NULL
	ALTER TABLE source_minor_location DROP COLUMN conversion_name 
