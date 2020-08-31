IF COL_LENGTH('source_deal_header', 'tier_value_id') IS NULL
BEGIN
    ALTER TABLE source_deal_header ADD tier_value_id INT 
END
GO

IF COL_LENGTH('delete_source_deal_header', 'tier_value_id') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_header ADD tier_value_id INT
END
GO

IF COL_LENGTH('source_deal_header_audit', 'tier_value_id') IS NULL
BEGIN
    ALTER TABLE source_deal_header_audit ADD tier_value_id INT
END
GO


IF COL_LENGTH('source_deal_header_template', 'tier_value_id') IS NULL
BEGIN
    ALTER TABLE source_deal_header_template ADD tier_value_id INT
END


