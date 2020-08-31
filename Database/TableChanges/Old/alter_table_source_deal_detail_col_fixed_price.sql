IF COL_LENGTH('source_deal_detail_audit', 'fixed_price') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ALTER COLUMN fixed_price NUMERIC(38,20)
END
GO