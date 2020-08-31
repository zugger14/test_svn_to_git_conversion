IF COL_LENGTH('deal_fields_mapping_contracts', 'subsidiary_id') IS NULL
BEGIN
    ALTER TABLE deal_fields_mapping_contracts ADD subsidiary_id INT REFERENCES fas_subsidiaries(fas_subsidiary_id)
END
GO