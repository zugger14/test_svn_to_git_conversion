IF EXISTS( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_minor_location' AND  COLUMN_NAME = 'address')
BEGIN
	PRINT 'Already exists'
END
ELSE
BEGIN
	ALTER TABLE source_minor_location ADD [address] VARCHAR(1000)	
END