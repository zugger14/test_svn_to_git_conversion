UPDATE gmd
SET clm2_label = 'Commodity'
FROM generic_mapping_header gmh
INNER JOIN generic_mapping_definition gmd
	ON gmh.mapping_table_id = gmd.mapping_table_id
WHERE gmh.mapping_name = 'Trayport Book Mapping'