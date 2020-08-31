IF COL_LENGTH('source_deal_header_template', 'contract_id') IS NULL
BEGIN
    ALTER TABLE source_deal_header_template ADD contract_id INT NULL
END
GO
