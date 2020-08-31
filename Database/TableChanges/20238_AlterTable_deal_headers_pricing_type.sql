IF COL_LENGTH('source_deal_header', 'pricing_type') IS NULL
BEGIN
    ALTER TABLE source_deal_header ADD pricing_type INT
END
GO

IF COL_LENGTH('source_deal_header_template', 'pricing_type') IS NULL
BEGIN
    ALTER TABLE source_deal_header_template ADD pricing_type INT
END
GO

IF COL_LENGTH('delete_source_deal_header', 'pricing_type') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_header ADD pricing_type INT
END
GO

IF COL_LENGTH('source_deal_header_audit', 'pricing_type') IS NULL
BEGIN
    ALTER TABLE source_deal_header_audit ADD pricing_type INT
END
GO