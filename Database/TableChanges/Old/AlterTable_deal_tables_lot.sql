IF COL_LENGTH('source_deal_detail', 'lot') IS NULL
BEGIN
    ALTER TABLE source_deal_detail ADD lot VARCHAR(500)
END
GO

IF COL_LENGTH('source_deal_detail_template', 'lot') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_template ADD lot VARCHAR(500)
END
GO

IF COL_LENGTH('delete_source_deal_detail', 'lot') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ADD lot VARCHAR(500)
END
GO

IF COL_LENGTH('source_deal_detail_audit', 'lot') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ADD lot VARCHAR(500)
END
GO