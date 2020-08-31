IF EXISTS( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_commodity' AND  COLUMN_NAME = 'valuation_curve')
BEGIN
	PRINT 'Already exists'
END
ELSE
BEGIN
	ALTER TABLE source_commodity ADD [valuation_curve] INT
END