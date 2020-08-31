IF COL_LENGTH('source_deal_detail', 'no_of_strikes') IS NULL
BEGIN
    ALTER TABLE source_deal_detail ADD no_of_strikes INT
END
GO

IF COL_LENGTH('source_deal_detail_template', 'no_of_strikes') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_template ADD no_of_strikes INT
END
GO

IF COL_LENGTH('delete_source_deal_detail', 'no_of_strikes') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ADD no_of_strikes INT
END
GO

IF COL_LENGTH('source_deal_detail_audit', 'no_of_strikes') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ADD no_of_strikes INT
END
GO