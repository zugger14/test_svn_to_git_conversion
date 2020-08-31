IF COL_LENGTH('source_deal_header_template', 'enable_exercise') IS NULL
BEGIN
    ALTER TABLE source_deal_header_template ADD enable_exercise CHAR(1)
END
GO