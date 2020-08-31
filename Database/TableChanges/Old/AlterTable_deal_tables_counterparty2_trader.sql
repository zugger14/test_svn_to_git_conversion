IF COL_LENGTH('source_deal_header', 'counterparty2_trader') IS NULL
BEGIN
    ALTER TABLE source_deal_header ADD counterparty2_trader INT
END
GO

IF COL_LENGTH('source_deal_header_template', 'counterparty2_trader') IS NULL
BEGIN
    ALTER TABLE source_deal_header_template ADD counterparty2_trader INT
END
GO

IF COL_LENGTH('delete_source_deal_header', 'counterparty2_trader') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_header ADD counterparty2_trader INT
END
GO

IF COL_LENGTH('source_deal_header_audit', 'counterparty2_trader') IS NULL
BEGIN
    ALTER TABLE source_deal_header_audit ADD counterparty2_trader INT
END
GO