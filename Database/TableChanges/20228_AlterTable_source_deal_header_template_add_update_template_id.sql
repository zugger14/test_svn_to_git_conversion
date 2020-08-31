IF COL_LENGTH('source_deal_header_template', 'update_template_id') IS NULL
BEGIN
    ALTER TABLE source_deal_header_template ADD update_template_id INT
END
GO