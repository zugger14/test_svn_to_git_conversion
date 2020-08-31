IF COL_LENGTH('deal_fields_mapping_locations', 'location_group') IS NULL
BEGIN
    ALTER TABLE deal_fields_mapping_locations ADD location_group INT REFERENCES source_major_location(source_major_location_ID)
END
GO

IF COL_LENGTH('deal_fields_mapping_locations', 'commodity_id') IS NULL
BEGIN
    ALTER TABLE deal_fields_mapping_locations ADD commodity_id INT REFERENCES source_commodity(source_commodity_id)
END
GO