IF COL_LENGTH('deal_price_deemed', 'pricing_index') IS NOT NULL
BEGIN
	ALTER TABLE deal_price_deemed ALTER COLUMN pricing_index INT NULL
END

IF COL_LENGTH('deal_price_std_event', 'pricing_index') IS NOT NULL
BEGIN
	ALTER TABLE deal_price_std_event ALTER COLUMN pricing_index INT NULL
END