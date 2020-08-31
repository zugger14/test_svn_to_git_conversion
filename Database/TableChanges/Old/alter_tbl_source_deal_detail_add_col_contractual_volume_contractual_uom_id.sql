--source_deal_detail_template
IF COL_LENGTH('source_deal_detail_template', 'contractual_volume') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_template ADD contractual_volume NUMERIC(38,18)
END
GO



IF COL_LENGTH('source_deal_detail_template', 'contractual_uom_id') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_template ADD contractual_uom_id INT
END
GO



--source_deal_detail

IF COL_LENGTH('source_deal_detail', 'contractual_volume') IS NULL
BEGIN
    ALTER TABLE source_deal_detail ADD contractual_volume NUMERIC(38,18)
END
GO



IF COL_LENGTH('source_deal_detail', 'contractual_uom_id') IS NULL
BEGIN
    ALTER TABLE source_deal_detail ADD contractual_uom_id INT
END
GO


--delete_source_deal_detail
IF COL_LENGTH('delete_source_deal_detail', 'contractual_volume') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ADD contractual_volume NUMERIC(38,18)
END
GO



IF COL_LENGTH('delete_source_deal_detail', 'contractual_uom_id') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ADD contractual_uom_id INT
END
GO


--source_deal_detail_audit
IF COL_LENGTH('source_deal_detail', 'contractual_volume') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ADD contractual_volume NUMERIC(38,18)
END
GO



IF COL_LENGTH('source_deal_detail_audit', 'contractual_uom_id') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ADD contractual_uom_id INT
END
GO
