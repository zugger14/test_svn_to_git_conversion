IF COL_LENGTH('source_deal_detail', 'volume_left') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail ALTER COLUMN volume_left NUMERIC(38,20)
END
GO

IF COL_LENGTH('source_deal_detail_audit', 'volume_left') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ALTER COLUMN volume_left NUMERIC(38,20)
END
GO