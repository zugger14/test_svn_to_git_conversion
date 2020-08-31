UPDATE gmd
	SET gmd.clm3_udf_id = udft.udf_template_id
FROM generic_mapping_definition gmd
INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id
INNER JOIN user_defined_fields_template udft ON udft.Field_label = 'Logical Name'
	AND gmh.mapping_name = 'Contract Value'