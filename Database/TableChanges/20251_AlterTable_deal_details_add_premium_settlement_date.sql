IF COL_LENGTH('source_deal_detail', 'premium_settlement_date') IS NULL
BEGIN
    ALTER TABLE source_deal_detail ADD premium_settlement_date DATETIME 
END
GO

IF COL_LENGTH('source_deal_detail_template', 'premium_settlement_date') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_template ADD premium_settlement_date DATETIME
END
GO

IF COL_LENGTH('delete_source_deal_detail', 'premium_settlement_date') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ADD premium_settlement_date DATETIME
END
GO

IF COL_LENGTH('source_deal_detail_audit', 'premium_settlement_date') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ADD premium_settlement_date DATETIME
END
GO