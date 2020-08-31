IF COL_LENGTH('source_deal_detail', 'standard_yearly_volume') IS NOT NULL
BEGIN
	ALTER TABLE source_deal_detail ALTER COLUMN standard_yearly_volume NUMERIC(22,8)
END
GO

IF COL_LENGTH('pratos_stage_deal_detail', 'syv') IS NOT NULL
BEGIN
	ALTER TABLE pratos_stage_deal_detail  ALTER COLUMN syv NUMERIC(22,8)
END
GO


