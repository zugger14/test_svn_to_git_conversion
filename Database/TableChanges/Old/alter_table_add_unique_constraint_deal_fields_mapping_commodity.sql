IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'UC_deal_fields_mapping_commodity')
BEGIN
	ALTER TABLE deal_fields_mapping_commodity
	ADD CONSTRAINT UC_deal_fields_mapping_commodity UNIQUE (deal_fields_mapping_id,detail_commodity_id)
END