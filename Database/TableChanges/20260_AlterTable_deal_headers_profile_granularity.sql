IF COL_LENGTH('source_deal_header', 'profile_granularity') IS NULL
BEGIN
    ALTER TABLE source_deal_header ADD profile_granularity INT REFERENCES static_data_value(value_id)
END
GO

IF COL_LENGTH('delete_source_deal_header', 'profile_granularity') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_header ADD profile_granularity INT
END
GO

IF COL_LENGTH('source_deal_header_audit', 'profile_granularity') IS NULL
BEGIN
    ALTER TABLE source_deal_header_audit ADD profile_granularity INT
END
GO