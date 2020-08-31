IF COL_LENGTH('source_deal_header', 'payment_days') IS NULL
BEGIN
    ALTER TABLE source_deal_header ADD payment_days INT
END
GO

IF COL_LENGTH('source_deal_header_template', 'payment_days') IS NULL
BEGIN
    ALTER TABLE source_deal_header_template ADD payment_days INT
END
GO

IF COL_LENGTH('delete_source_deal_header', 'payment_days') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_header ADD payment_days INT
END
GO

IF COL_LENGTH('source_deal_header_audit', 'payment_days') IS NULL
BEGIN
    ALTER TABLE source_deal_header_audit ADD payment_days INT
END
GO