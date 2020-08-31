IF EXISTS( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_commodity' AND  COLUMN_NAME = 'commodity_group1')
BEGIN
	PRINT 'Already exists'
END
ELSE
BEGIN
	ALTER TABLE source_commodity ADD [commodity_group1] INT
END

IF EXISTS( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_commodity' AND  COLUMN_NAME = 'commodity_group2')
BEGIN
	PRINT 'Already exists'
END
ELSE
BEGIN
	ALTER TABLE source_commodity ADD [commodity_group2] INT
END

IF EXISTS( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_commodity' AND  COLUMN_NAME = 'commodity_group3')
BEGIN
	PRINT 'Already exists'
END
ELSE
BEGIN
	ALTER TABLE source_commodity ADD [commodity_group3] INT
END

IF EXISTS( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_commodity' AND  COLUMN_NAME = 'commodity_group4')
BEGIN
	PRINT 'Already exists'
END
ELSE
BEGIN
	ALTER TABLE source_commodity ADD [commodity_group4] INT
END