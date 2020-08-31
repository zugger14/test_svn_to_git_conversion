IF COL_LENGTH('source_deal_header_template', 'collateral_amount') IS NULL
BEGIN
    ALTER TABLE source_deal_header_template ADD collateral_amount NUMERIC(38, 20)
END
GO

IF COL_LENGTH('source_deal_header', 'collateral_amount') IS NULL
BEGIN
    ALTER TABLE source_deal_header ADD collateral_amount NUMERIC(38, 20)
END
GO

IF COL_LENGTH('delete_source_deal_header', 'collateral_amount') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_header ADD collateral_amount NUMERIC(38, 20)
END
GO

IF COL_LENGTH('source_deal_header_audit', 'collateral_amount') IS NULL
BEGIN
    ALTER TABLE source_deal_header_audit ADD collateral_amount NUMERIC(38, 20)
END
GO