IF COL_LENGTH('source_deal_header_template', 'certificate') IS NULL
BEGIN
    ALTER TABLE source_deal_header_template ADD [certificate] CHAR(1)
END

