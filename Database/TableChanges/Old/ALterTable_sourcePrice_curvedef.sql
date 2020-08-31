IF COL_LENGTH('source_Price_curve_def', 'ratio_option') IS NULL
BEGIN
	ALTER TABLE source_Price_curve_def ADD ratio_option INT
	PRINT 'Column source_Price_curve_def.ratio_option added.'
END
ELSE
BEGIN
	PRINT 'Column source_Price_curve_def.ratio_option already exists.'
END
GO 

