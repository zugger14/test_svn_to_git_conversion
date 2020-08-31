IF COL_LENGTH('source_deal_header_template', 'enable_efp') IS NULL
BEGIN
    ALTER TABLE source_deal_header_template ADD enable_efp CHAR(1)
END
GO

IF COL_LENGTH('source_deal_header_template', 'enable_trigger') IS NULL
BEGIN
    ALTER TABLE source_deal_header_template ADD enable_trigger CHAR(1)
END
GO