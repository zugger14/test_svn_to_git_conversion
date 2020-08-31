IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'UC_deal_fields_mapping_locations')
BEGIN
	ALTER TABLE deal_fields_mapping_locations
	ADD CONSTRAINT UC_deal_fields_mapping_locations UNIQUE (deal_fields_mapping_id,location_id)
END