IF COL_LENGTH('source_deal_header', 'confirmation_type') IS NULL
BEGIN
    ALTER TABLE source_deal_header ADD confirmation_type INT REFERENCES static_data_value(value_id)
END
GO

IF COL_LENGTH('source_deal_header_template', 'confirmation_type') IS NULL
BEGIN
    ALTER TABLE source_deal_header_template ADD confirmation_type INT
END
GO

IF COL_LENGTH('delete_source_deal_header', 'confirmation_type') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_header ADD confirmation_type INT
END
GO

IF COL_LENGTH('source_deal_header_audit', 'confirmation_type') IS NULL
BEGIN
    ALTER TABLE source_deal_header_audit ADD confirmation_type INT
END
GO