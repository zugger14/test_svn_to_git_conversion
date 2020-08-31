IF COL_LENGTH('source_deal_detail', 'upstream_contract') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail ALTER COLUMN upstream_contract VARCHAR(500)
END
GO

IF COL_LENGTH('source_deal_detail_template', 'upstream_contract') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail_template ALTER COLUMN upstream_contract VARCHAR(500)
END
GO

IF COL_LENGTH('delete_source_deal_detail', 'upstream_contract') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ALTER COLUMN upstream_contract VARCHAR(500)
END
GO

IF COL_LENGTH('source_deal_detail_audit', 'upstream_contract') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ALTER COLUMN upstream_contract VARCHAR(500)
END
GO