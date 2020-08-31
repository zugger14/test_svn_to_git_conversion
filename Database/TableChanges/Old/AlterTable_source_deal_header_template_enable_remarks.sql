IF COL_LENGTH('source_deal_header_template', 'enable_remarks') IS NULL
BEGIN
    ALTER TABLE source_deal_header_template ADD enable_remarks CHAR(1)
END
GO