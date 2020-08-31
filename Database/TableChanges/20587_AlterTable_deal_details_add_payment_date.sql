IF COL_LENGTH('source_deal_detail', 'payment_date') IS NULL
BEGIN
    ALTER TABLE source_deal_detail ADD payment_date DATETIME 
END
GO

IF COL_LENGTH('source_deal_detail_template', 'payment_date') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_template ADD payment_date DATETIME
END
GO

IF COL_LENGTH('delete_source_deal_detail', 'payment_date') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ADD payment_date DATETIME
END
GO

IF COL_LENGTH('source_deal_detail_audit', 'payment_date') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ADD payment_date DATETIME
END
GO