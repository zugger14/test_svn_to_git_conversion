IF COL_LENGTH('source_deal_header_template', 'collateral_req_per') IS NULL
BEGIN
    ALTER TABLE source_deal_header_template ADD collateral_req_per FLOAT
END
GO

IF COL_LENGTH('source_deal_header', 'collateral_req_per') IS NULL
BEGIN
    ALTER TABLE source_deal_header ADD collateral_req_per FLOAT
END
GO

IF COL_LENGTH('delete_source_deal_header', 'collateral_req_per') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_header ADD collateral_req_per FLOAT
END
GO

IF COL_LENGTH('source_deal_header_audit', 'collateral_req_per') IS NULL
BEGIN
    ALTER TABLE source_deal_header_audit ADD collateral_req_per FLOAT
END
GO