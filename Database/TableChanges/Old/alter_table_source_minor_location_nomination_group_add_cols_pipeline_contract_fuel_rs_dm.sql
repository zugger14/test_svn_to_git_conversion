/*
ALTER TABLE TO ADD COLUMNS
DATE: 2015-03-16
sligal@pioneersolutionsglobal.com
*/
IF COL_LENGTH(N'source_minor_location_nomination_group', 'pipeline') IS NULL
BEGIN
	ALTER TABLE source_minor_location_nomination_group ADD pipeline INT REFERENCES source_counterparty (source_counterparty_id) 
		ON DELETE SET NULL
END

IF COL_LENGTH(N'source_minor_location_nomination_group', 'contract_id') IS NULL
BEGIN
	ALTER TABLE source_minor_location_nomination_group ADD contract_id INT REFERENCES contract_group (contract_id) 
		ON DELETE SET NULL
END

IF COL_LENGTH(N'source_minor_location_nomination_group', 'fuel_percent') IS NULL
BEGIN
	ALTER TABLE source_minor_location_nomination_group ADD fuel_percent FLOAT
END

IF COL_LENGTH(N'source_minor_location_nomination_group', 'rate_schedule') IS NULL
BEGIN
	ALTER TABLE source_minor_location_nomination_group ADD rate_schedule INT
END

IF COL_LENGTH(N'source_minor_location_nomination_group', 'delivery_meter_id') IS NULL
BEGIN
	ALTER TABLE source_minor_location_nomination_group ADD delivery_meter_id INT REFERENCES meter_id (meter_id) 
		ON DELETE SET NULL
END
