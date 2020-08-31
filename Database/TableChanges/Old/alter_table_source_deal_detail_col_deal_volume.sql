IF COL_LENGTH('source_deal_detail_audit', 'deal_volume') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ALTER COLUMN deal_volume NUMERIC(38,20)
END
GO