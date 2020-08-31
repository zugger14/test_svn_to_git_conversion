IF COL_LENGTH('source_deal_detail_audit', 'deal_volume') IS NOT NULL
BEGIN
	ALTER TABLE source_deal_detail_audit ALTER COLUMN deal_volume NUMERIC(38, 9)
END

IF COL_LENGTH('source_deal_detail_audit', 'volume_left') IS NOT NULL
BEGIN
	ALTER TABLE source_deal_detail_audit ALTER COLUMN volume_left NUMERIC(38, 9)
END