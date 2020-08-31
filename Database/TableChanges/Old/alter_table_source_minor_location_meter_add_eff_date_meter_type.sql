IF COL_LENGTH('source_minor_location_meter', 'effective_date') IS NULL
BEGIN
	ALTER TABLE source_minor_location_meter
	ADD effective_date DATETIME
	PRINT 'Column effective_date added.'
END
ELSE PRINT 'Column effective_date already exists.'

IF COL_LENGTH('source_minor_location_meter', 'meter_type') IS NULL
BEGIN
	ALTER TABLE source_minor_location_meter
	ADD meter_type INT
	PRINT 'Column meter_type added.'
END
ELSE PRINT 'Column meter_type already exists.'