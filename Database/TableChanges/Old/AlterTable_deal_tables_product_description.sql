IF COL_LENGTH('source_deal_detail', 'product_description') IS NULL
BEGIN
    ALTER TABLE source_deal_detail ADD product_description VARCHAR(2000)
END
GO

IF COL_LENGTH('source_deal_detail_template', 'product_description') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_template ADD product_description VARCHAR(2000)
END
GO

IF COL_LENGTH('delete_source_deal_detail', 'product_description') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ADD product_description VARCHAR(2000)
END
GO

IF COL_LENGTH('source_deal_detail_audit', 'product_description') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ADD product_description VARCHAR(2000)
END
GO