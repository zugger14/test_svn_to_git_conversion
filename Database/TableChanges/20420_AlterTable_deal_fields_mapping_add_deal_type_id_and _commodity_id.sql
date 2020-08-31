IF COL_LENGTH('deal_fields_mapping', 'deal_type_id') IS NULL
BEGIN
    ALTER TABLE deal_fields_mapping ADD deal_type_id INT
END
GO

IF COL_LENGTH('deal_fields_mapping', 'commodity_id') IS NULL
BEGIN
    ALTER TABLE deal_fields_mapping ADD commodity_id INT
END
GO