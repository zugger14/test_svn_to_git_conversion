IF COL_LENGTH('deal_fields_mapping_curves', 'commodity_id') IS NULL
BEGIN
    ALTER TABLE deal_fields_mapping_curves ADD commodity_id INT REFERENCES source_commodity(source_commodity_id)
END
GO

IF COL_LENGTH('deal_fields_mapping_curves', 'index_group') IS NULL
BEGIN
    ALTER TABLE deal_fields_mapping_curves ADD index_group INT REFERENCES static_data_value(value_id)
END
GO

IF COL_LENGTH('deal_fields_mapping_curves', 'market') IS NULL
BEGIN
    ALTER TABLE deal_fields_mapping_curves ADD market INT  REFERENCES static_data_value(value_id)
END
GO