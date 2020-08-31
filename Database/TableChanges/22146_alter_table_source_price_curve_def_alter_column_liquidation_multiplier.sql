IF COL_LENGTH('source_price_curve_def', 'liquidation_multiplier') IS NOT NULL
BEGIN
	ALTER TABLE source_price_curve_def ALTER COLUMN liquidation_multiplier INT
END
ELSE
BEGIN
	PRINT 'Column ''liquidation_multiplier'' doesn''t exists.'
END