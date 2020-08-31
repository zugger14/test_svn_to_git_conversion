IF COL_LENGTH('source_deal_detail', 'batch_id') IS NULL
BEGIN
    ALTER TABLE source_deal_detail ADD batch_id VARCHAR(500)
END
GO

IF COL_LENGTH('source_deal_detail_template', 'batch_id') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_template ADD batch_id VARCHAR(500)
END
GO

IF COL_LENGTH('delete_source_deal_detail', 'batch_id') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ADD batch_id VARCHAR(500)
END
GO

IF COL_LENGTH('source_deal_detail_audit', 'batch_id') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ADD batch_id VARCHAR(500)
END
GO