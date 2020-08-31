IF COL_LENGTH('source_deal_detail', 'pricing_type2') IS NULL
BEGIN
    ALTER TABLE source_deal_detail ADD pricing_type2 INT
END
GO

IF COL_LENGTH('source_deal_detail_template', 'pricing_type2') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_template ADD pricing_type2 INT
END
GO

IF COL_LENGTH('delete_source_deal_detail', 'pricing_type2') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ADD pricing_type2 INT
END
GO

IF COL_LENGTH('source_deal_detail_audit', 'pricing_type2') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ADD pricing_type2 INT
END
