IF COL_LENGTH('source_deal_detail', 'strike_granularity') IS NULL
BEGIN
    ALTER TABLE source_deal_detail ADD strike_granularity INT REFERENCES static_data_value(value_id)
END
GO

IF COL_LENGTH('source_deal_detail_template', 'strike_granularity') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_template ADD strike_granularity INT
END
GO

IF COL_LENGTH('delete_source_deal_detail', 'strike_granularity') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ADD strike_granularity INT
END
GO

IF COL_LENGTH('source_deal_detail_audit', 'strike_granularity') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ADD strike_granularity INT
END
GO