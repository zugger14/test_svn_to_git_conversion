IF COL_LENGTH('regression_module_detail', 'compare_columns') IS NOT NULL
BEGIN
	ALTER TABLE regression_module_detail 
	ALTER COLUMN compare_columns VARCHAR(5000)
	print 'success'
END

IF COL_LENGTH('regression_module_detail', 'display_columns') IS NOT NULL
BEGIN
	ALTER TABLE regression_module_detail 
	ALTER COLUMN display_columns VARCHAR(5000)
	print 'success'
END

IF COL_LENGTH('regression_module_detail', 'unique_columns') IS NOT NULL
BEGIN
	ALTER TABLE regression_module_detail 
	ALTER COLUMN unique_columns VARCHAR(5000)
	print 'success'
END