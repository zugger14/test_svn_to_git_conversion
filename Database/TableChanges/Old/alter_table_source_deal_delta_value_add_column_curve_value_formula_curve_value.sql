IF COL_LENGTH('source_deal_delta_value','curve_value') IS NULL
BEGIN
	ALTER TABLE source_deal_delta_value add curve_value FLOAT
END
ELSE 
	PRINT 'Column curve_value Already Exists.'
	
IF COL_LENGTH('source_deal_delta_value','formula_curve_value') IS NULL
BEGIN
	ALTER TABLE source_deal_delta_value add formula_curve_value FLOAT
END
ELSE 
	PRINT 'Column formula_curve_value Already Exists.'	