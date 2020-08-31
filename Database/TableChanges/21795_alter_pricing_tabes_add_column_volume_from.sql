IF COL_LENGTH('deal_price_deemed', 'volume_from') IS NULL
BEGIN
	ALTER TABLE deal_price_deemed ADD volume_from NUMERIC(38, 17)
END

IF COL_LENGTH('deal_price_std_event', 'volume_from') IS NULL
BEGIN
	ALTER TABLE deal_price_std_event ADD volume_from NUMERIC(38, 17)
END

IF COL_LENGTH('deal_price_custom_event', 'volume_from') IS NULL
BEGIN
	ALTER TABLE deal_price_custom_event ADD volume_from NUMERIC(38, 17)
END