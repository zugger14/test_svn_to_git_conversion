IF COL_LENGTH('source_deal_header', 'arbitration') IS NULL
BEGIN
    ALTER TABLE source_deal_header ADD arbitration INT
END
GO

IF COL_LENGTH('source_deal_header_template', 'arbitration') IS NULL
BEGIN
    ALTER TABLE source_deal_header_template ADD arbitration INT
END
GO

IF COL_LENGTH('delete_source_deal_header', 'arbitration') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_header ADD arbitration INT
END
GO

IF COL_LENGTH('source_deal_header_audit', 'arbitration') IS NULL
BEGIN
    ALTER TABLE source_deal_header_audit ADD arbitration INT
END
GO