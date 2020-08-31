IF COL_LENGTH('user_defined_fields_template', 'multiplier') IS NULL
	ALTER TABLE user_defined_fields_template ADD multiplier INT