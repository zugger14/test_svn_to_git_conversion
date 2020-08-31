IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_price_curve_def' AND COLUMN_NAME = 'curve_definition')
BEGIN
	ALTER TABLE source_price_curve_def ADD curve_definition VARCHAR(max)
END


