IF COL_LENGTH('source_deal_detail_audit', 'deal_volume') IS NOT NULL
BEGIN
	ALTER TABLE source_deal_detail_audit ALTER COLUMN deal_volume NUMERIC(38,20)
END
GO

IF COL_LENGTH('source_deal_detail_audit', 'capacity') IS NOT NULL
BEGIN
	ALTER TABLE source_deal_detail_audit ALTER COLUMN capacity NUMERIC(38,20)
END
GO

IF COL_LENGTH('source_deal_detail_audit', 'total_volume') IS NOT NULL
BEGIN
	ALTER TABLE source_deal_detail_audit ALTER COLUMN total_volume NUMERIC(38,20)
END
GO

IF COL_LENGTH('source_deal_detail_audit', 'price_adder') IS NOT NULL
BEGIN
	ALTER TABLE source_deal_detail_audit ALTER COLUMN price_adder NUMERIC(38,20)
END
GO

IF COL_LENGTH('source_deal_detail_audit', 'price_adder2') IS NOT NULL
BEGIN
	ALTER TABLE source_deal_detail_audit ALTER COLUMN price_adder2 NUMERIC(38,20)
END
GO

IF COL_LENGTH('source_deal_detail_audit', 'price_multiplier') IS NOT NULL
BEGIN
	ALTER TABLE source_deal_detail_audit ALTER COLUMN price_multiplier NUMERIC(38,20)
END
GO

IF COL_LENGTH('source_deal_detail_audit', 'fixed_cost') IS NOT NULL
BEGIN
	ALTER TABLE source_deal_detail_audit ALTER COLUMN fixed_cost NUMERIC(38,20)
END
GO

IF COL_LENGTH('source_deal_detail_audit', 'fixed_price') IS NOT NULL
BEGIN
	ALTER TABLE source_deal_detail_audit ALTER COLUMN fixed_price NUMERIC(38,20)
END
GO

IF COL_LENGTH('source_deal_detail_audit', 'option_strike_price') IS NOT NULL
BEGIN
	ALTER TABLE source_deal_detail_audit ALTER COLUMN option_strike_price NUMERIC(38,20)
END
GO

IF COL_LENGTH('source_deal_detail_audit', 'standard_yearly_volume') IS NOT NULL
BEGIN
	ALTER TABLE source_deal_detail_audit ALTER COLUMN standard_yearly_volume NUMERIC(38,20)
END
GO

IF COL_LENGTH('source_deal_detail_audit', 'volume_multiplier2') IS NOT NULL
BEGIN
	ALTER TABLE source_deal_detail_audit ALTER COLUMN volume_multiplier2 NUMERIC(38,20)
END
GO

IF COL_LENGTH('source_deal_detail_audit', 'multiplier') IS NOT NULL
BEGIN
	ALTER TABLE source_deal_detail_audit ALTER COLUMN multiplier NUMERIC(38,20)
END
GO

IF COL_LENGTH('source_deal_detail_audit', 'volume_left') IS NOT NULL
BEGIN
	ALTER TABLE source_deal_detail_audit ALTER COLUMN volume_left NUMERIC(38,20)
END
GO

IF COL_LENGTH('source_deal_detail_audit', 'settlement_volume') IS NOT NULL
BEGIN
	ALTER TABLE source_deal_detail_audit ALTER COLUMN settlement_volume NUMERIC(38,20)
END
GO