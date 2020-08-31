UPDATE gmd SET unique_columns_index = '1,2,4,5'	
FROM   generic_mapping_definition gmd
INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'Value Mapping'
