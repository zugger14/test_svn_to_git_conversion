IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'ICE Book Mapping')

	BEGIN
		UPDATE gmd
		SET 
			clm3_label = NULL,
			clm3_udf_id = NULL
			FROM  generic_mapping_definition gmd
		INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
		WHERE  gmh.mapping_name = 'ICE Book Mapping'
	
		UPDATE gmv
		SET
			clm3_value = NULL
			FROM   generic_mapping_values gmv
		INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmv.mapping_table_id
		WHERE  gmh.mapping_name = 'ICE Book Mapping'
	END