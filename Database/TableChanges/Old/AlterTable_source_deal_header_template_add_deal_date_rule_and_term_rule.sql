IF COL_LENGTH('source_deal_header_template', 'deal_date_rule') IS NULL
BEGIN
    ALTER TABLE source_deal_header_template ADD deal_date_rule INT
END
GO

IF COL_LENGTH('source_deal_header_template', 'term_rule') IS NULL
BEGIN
    ALTER TABLE source_deal_header_template ADD term_rule INT
END
GO