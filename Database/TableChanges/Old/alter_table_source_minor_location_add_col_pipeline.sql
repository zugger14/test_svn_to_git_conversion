/*
ALTER TABLE TO ADD COLUMN PIPELINE
DATE: 2015-03-16
sligal@pioneersolutionsglobal.com
*/
IF COL_LENGTH(N'source_minor_location', 'pipeline') IS NULL
BEGIN
	ALTER TABLE source_minor_location ADD pipeline INT REFERENCES source_counterparty (source_counterparty_id) 
		ON DELETE SET NULL
END