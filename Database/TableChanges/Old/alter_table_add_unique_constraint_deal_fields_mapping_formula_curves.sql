IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'UC_deal_fields_mapping_formula_curves')
BEGIN
	ALTER TABLE deal_fields_mapping_formula_curves
	ADD CONSTRAINT UC_deal_fields_mapping_formula_curves UNIQUE (deal_fields_mapping_id,formula_curve_id)
END