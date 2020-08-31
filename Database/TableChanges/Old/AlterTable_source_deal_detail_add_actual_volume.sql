IF COL_LENGTH('source_deal_detail', 'actual_volume') IS NULL
BEGIN
    ALTER TABLE source_deal_detail ADD actual_volume NUMERIC(38, 20)
END
GO

IF COL_LENGTH('source_deal_detail_template', 'actual_volume') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_template ADD actual_volume NUMERIC(38,20)
END
GO

IF COL_LENGTH('delete_source_deal_detail', 'actual_volume') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ADD actual_volume NUMERIC(38,20)
END
GO


IF COL_LENGTH('source_deal_detail_audit', 'actual_volume') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ADD actual_volume NUMERIC(38,20)
END
