IF COL_LENGTH('source_deal_header_template', 'enable_provisional_tab') IS NULL
BEGIN
    ALTER TABLE source_deal_header_template ADD enable_provisional_tab CHAR(1) DEFAULT 'n'
END
GO