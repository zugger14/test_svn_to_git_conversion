IF COL_LENGTH('source_deal_detail', 'buyer_seller_option') IS NULL
BEGIN
    ALTER TABLE source_deal_detail ADD buyer_seller_option INT
END
GO

IF COL_LENGTH('source_deal_detail_template', 'buyer_seller_option') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_template ADD buyer_seller_option INT
END
GO

IF COL_LENGTH('delete_source_deal_detail', 'buyer_seller_option') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ADD buyer_seller_option INT
END
GO

IF COL_LENGTH('source_deal_detail_audit', 'buyer_seller_option') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ADD buyer_seller_option INT
END
GO