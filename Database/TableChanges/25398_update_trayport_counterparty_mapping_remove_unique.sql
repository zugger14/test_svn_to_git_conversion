UPDATE gmd 
SET unique_columns_index = NULL
FROM generic_mapping_definition gmd
INNER JOIN generic_mapping_header gmh
	ON gmd.mapping_table_id = gmh.mapping_table_id
WHERE gmh.mapping_name = 'Trayport Counterparty Mapping'