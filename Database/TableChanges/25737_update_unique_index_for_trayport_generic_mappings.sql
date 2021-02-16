UPDATE gmd
	SET unique_columns_index = NULL
FROM generic_mapping_header gmh
INNER JOIN generic_mapping_definition gmd
	ON gmd.mapping_table_id = gmh.mapping_table_id
WHERE mapping_name IN ('Trayport location Mapping'
						,'Trayport product Mapping'
						,'Trayport Broker Mapping'
						,'Trayport Trader Mapping'
						,'Trayport Counterparty Mapping'
						,'Trayport Book Mapping'
						,'Trayport Contract Mapping'
						,'Trayport Block Definition Product Mapping'
						,'Trayport Autopath Mapping')