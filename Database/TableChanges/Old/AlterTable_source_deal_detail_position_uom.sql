-- position_uom
IF COL_LENGTH('source_deal_detail', 'position_uom') IS NULL
BEGIN
    ALTER TABLE source_deal_detail ADD position_uom INT
END
GO

IF COL_LENGTH('source_deal_detail_template', 'position_uom') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_template ADD position_uom INT
END
GO

IF COL_LENGTH('delete_source_deal_detail', 'position_uom') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ADD position_uom INT
END
GO

IF COL_LENGTH('source_deal_detail_audit', 'position_uom') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ADD position_uom INT
END
GO