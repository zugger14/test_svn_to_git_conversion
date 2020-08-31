IF COL_LENGTH('source_deal_header', 'confirmation_template') IS NULL
BEGIN
    ALTER TABLE source_deal_header ADD confirmation_template INT REFERENCES contract_report_template(template_id)
END
GO

IF COL_LENGTH('source_deal_header_template', 'confirmation_template') IS NULL
BEGIN
    ALTER TABLE source_deal_header_template ADD confirmation_template INT
END
GO

IF COL_LENGTH('delete_source_deal_header', 'confirmation_template') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_header ADD confirmation_template INT
END
GO

IF COL_LENGTH('source_deal_header_audit', 'confirmation_template') IS NULL
BEGIN
    ALTER TABLE source_deal_header_audit ADD confirmation_template INT
END
GO

