IF COL_LENGTH('pnl_categories_mapping', 'sub_id') IS NULL
BEGIN
	ALTER TABLE pnl_categories_mapping ADD sub_id INT
	PRINT 'Column sub_id.granularity added.'
END
ELSE
BEGIN
	PRINT 'Column pnl_categories_mapping.sub_id already exists.'
END
GO

IF COL_LENGTH('pnl_categories_mapping', 'deferral') IS NULL
BEGIN
	ALTER TABLE pnl_categories_mapping ADD deferral VARCHAR(50)
	PRINT 'Column pnl_categories_mapping.deferral added.'
END
ELSE
BEGIN
	PRINT 'Column pnl_categories_mapping.deferral already exists.'
END
GO