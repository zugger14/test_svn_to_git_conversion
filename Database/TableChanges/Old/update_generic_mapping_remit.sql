IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE code = 'Time (HH:MM:SS)')
UPDATE static_data_value
SET code = 'Time (HH:MM:SS)'
WHERE code = 'Time'

IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE field_label = 'Time (HH:MM:SS)')
UPDATE user_defined_fields_template
SET field_label = 'Time (HH:MM:SS)'
WHERE field_label = 'Time'

UPDATE gmd
SET clm4_label = 'Time (HH:MM:SS)'
FROM generic_mapping_definition gmd
INNER JOIN generic_mapping_header gmh
  ON gmh.mapping_table_id = gmd.mapping_table_id
WHERE gmh.mapping_name = 'Remit Invoice Date'

UPDATE gmd
SET clm9_label = NULL,
    clm9_udf_id = NULL,
	required_columns_index = '1,2,3,4,5,6,7,8'
FROM generic_mapping_definition gmd
INNER JOIN generic_mapping_header gmh
  ON gmh.mapping_table_id = gmd.mapping_table_id
WHERE gmh.mapping_name = 'Remit Execution'

UPDATE gmd
SET clm9_value = NULL
FROM generic_mapping_values gmd
INNER JOIN generic_mapping_header gmh
  ON gmh.mapping_table_id = gmd.mapping_table_id
WHERE gmh.mapping_name = 'Remit Execution'