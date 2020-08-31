IF COL_LENGTH('source_deal_header_template', 'enable_pricing_tabs') IS NULL
BEGIN
    ALTER TABLE source_deal_header_template ADD enable_pricing_tabs CHAR(1)
END
GO

UPDATE source_deal_header_template
SET enable_pricing_tabs = 'n'
WHERE enable_pricing_tabs IS NULL