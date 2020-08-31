IF COL_LENGTH('curve_volatility', 'value') IS NOT NULL 
	ALTER TABLE curve_volatility ALTER COLUMN value float NULL
