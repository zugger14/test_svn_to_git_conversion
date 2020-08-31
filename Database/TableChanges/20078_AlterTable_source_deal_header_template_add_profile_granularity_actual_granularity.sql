IF COL_LENGTH('source_deal_header_template', 'profile_granularity') IS NULL
BEGIN
    ALTER TABLE source_deal_header_template ADD profile_granularity INT
END
GO

IF COL_LENGTH('source_deal_header_template', 'actual_granularity') IS NULL
BEGIN
    ALTER TABLE source_deal_header_template ADD actual_granularity INT
END
GO