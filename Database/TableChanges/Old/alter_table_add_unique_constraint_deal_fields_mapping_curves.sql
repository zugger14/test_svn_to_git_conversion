IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'UC_deal_fields_mapping_curves')
BEGIN
	ALTER TABLE deal_fields_mapping_curves
	ADD CONSTRAINT UC_deal_fields_mapping_curves UNIQUE (deal_fields_mapping_id,curve_id)
END