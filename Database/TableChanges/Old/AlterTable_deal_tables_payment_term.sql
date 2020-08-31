IF COL_LENGTH('source_deal_header', 'payment_term') IS NULL
BEGIN
    ALTER TABLE source_deal_header ADD payment_term INT
END
GO

IF COL_LENGTH('source_deal_header_template', 'payment_term') IS NULL
BEGIN
    ALTER TABLE source_deal_header_template ADD payment_term INT
END
GO

IF COL_LENGTH('delete_source_deal_header', 'payment_term') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_header ADD payment_term INT
END
GO

IF COL_LENGTH('source_deal_header_audit', 'payment_term') IS NULL
BEGIN
    ALTER TABLE source_deal_header_audit ADD payment_term INT
END
GO