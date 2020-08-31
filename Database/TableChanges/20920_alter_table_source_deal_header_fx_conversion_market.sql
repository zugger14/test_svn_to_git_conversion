--source_deal_header
IF COL_LENGTH('source_deal_header', 'fx_conversion_market') IS NULL
BEGIN
    ALTER TABLE source_deal_header ADD fx_conversion_market INT
END
GO

IF COL_LENGTH('delete_source_deal_header', 'fx_conversion_market') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_header ADD fx_conversion_market INT
END
GO

IF COL_LENGTH('source_deal_header_audit', 'fx_conversion_market') IS NULL
BEGIN
    ALTER TABLE source_deal_header_audit ADD fx_conversion_market INT
END
GO


IF COL_LENGTH('source_deal_header_template', 'fx_conversion_market') IS NULL
BEGIN
    ALTER TABLE source_deal_header_template ADD fx_conversion_market INT
END
