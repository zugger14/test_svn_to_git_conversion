IF EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_price_curve_def' AND COLUMN_NAME = 'market_value_id')
BEGIN
	ALTER TABLE source_price_curve_def ALTER COLUMN market_value_id VARCHAR(50) NULL
END

GO

IF EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_price_curve_def_audit' AND COLUMN_NAME = 'market_value_id')
BEGIN
	ALTER TABLE source_price_curve_def_audit ALTER COLUMN market_value_id VARCHAR(50) NULL
END

