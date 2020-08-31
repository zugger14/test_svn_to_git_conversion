/**
* alter source_deal_delta_value, add formula_curve_id int null
**/
IF COL_LENGTH('source_deal_delta_value', 'formula_curve_id') IS NULL
BEGIN
	ALTER TABLE source_deal_delta_value
	ADD formula_curve_id INT NULL
END
ELSE
	PRINT 'column already exists.'