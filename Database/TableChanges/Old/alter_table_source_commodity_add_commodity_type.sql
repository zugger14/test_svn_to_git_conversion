IF EXISTS( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_commodity' AND  COLUMN_NAME = 'commodity_type')
BEGIN
	PRINT 'Column commodity_type Already exists'
END
ELSE
BEGIN
	ALTER TABLE source_commodity ADD commodity_type INT
	PRINT 'Column commodity_type Added'
END