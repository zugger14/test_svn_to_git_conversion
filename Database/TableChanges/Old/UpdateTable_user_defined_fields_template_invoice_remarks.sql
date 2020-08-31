UPDATE user_defined_fields_template
SET    field_size = 2000,
		data_type = 'VARCHAR(2000)'
WHERE  Field_label = 'Invoice Remarks'