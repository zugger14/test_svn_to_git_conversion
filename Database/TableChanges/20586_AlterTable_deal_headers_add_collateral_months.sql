IF COL_LENGTH('source_deal_header_template', 'collateral_months') IS NULL
BEGIN
    ALTER TABLE source_deal_header_template ADD collateral_months INT
END
GO

IF COL_LENGTH('source_deal_header', 'collateral_months') IS NULL
BEGIN
    ALTER TABLE source_deal_header ADD collateral_months INT
END
GO

IF COL_LENGTH('delete_source_deal_header', 'collateral_months') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_header ADD collateral_months INT
END
GO

IF COL_LENGTH('source_deal_header_audit', 'collateral_months') IS NULL
BEGIN
    ALTER TABLE source_deal_header_audit ADD collateral_months INT
END
GO