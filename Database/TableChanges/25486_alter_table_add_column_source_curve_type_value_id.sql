IF COL_LENGTH('deal_fields_mapping_formula_curves', 'source_curve_type_value_id') IS  NULL
BEGIN
	ALTER TABLE 
	/**
	Columns 
	source_curve_type_value_id: source_curve_type_value_id
	*/
	deal_fields_mapping_formula_curves ADD source_curve_type_value_id INT
END

IF COL_LENGTH('deal_fields_mapping_curves', 'source_curve_type_value_id') IS NULL
BEGIN
	ALTER TABLE 
	/**
	Columns 
	source_curve_type_value_id: source_curve_type_value_id
	*/
	deal_fields_mapping_curves ADD source_curve_type_value_id INT
END
