IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'portfolio_mapping_book' AND COLUMN_NAME = 'book_name')
BEGIN
	ALTER TABLE portfolio_mapping_book DROP COLUMN book_name
	PRINT 'Column dropped.'
END
ELSE
	PRINT 'Column does not exist.'
	
IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'portfolio_mapping_book' AND COLUMN_NAME = 'book_description')
BEGIN
	ALTER TABLE portfolio_mapping_book DROP COLUMN book_description
	PRINT 'Column dropped.'
END
ELSE
	PRINT 'Column does not exist.'

IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'portfolio_mapping_book' AND COLUMN_NAME = 'book_parameter')
BEGIN
	ALTER TABLE portfolio_mapping_book DROP COLUMN book_parameter
	PRINT 'Column dropped.'
END
ELSE
	PRINT 'Column does not exist.'
	
IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'portfolio_mapping_book' AND COLUMN_NAME = 'entity_id')
BEGIN
	ALTER TABLE portfolio_mapping_book ADD [entity_id] INT NULL
	PRINT 'Column added.'
END
ELSE
	PRINT 'Column already exists.'	