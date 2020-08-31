IF COL_LENGTH('source_price_curve_def', 'conversion_value_id') IS NULL
BEGIN
	ALTER TABLE source_price_curve_def 
	ADD conversion_value_id INT NULL
END
ELSE 
	PRINT('Column conversion_value_id already exists')	
GO