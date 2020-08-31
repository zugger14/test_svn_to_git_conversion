IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_minor_location_nomination_group' AND  COLUMN_NAME = 'primary_interconnect')
BEGIN
	ALTER TABLE source_minor_location_nomination_group ADD primary_interconnect INT
END
ELSE 
	PRINT 'Column already exists.'
	
IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_minor_location_nomination_group' AND  COLUMN_NAME = 'secondary_interconnect')
BEGIN
	ALTER TABLE source_minor_location_nomination_group ADD secondary_interconnect INT
END
ELSE 
	PRINT 'Column already exists.'