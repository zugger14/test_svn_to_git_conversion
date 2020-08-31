IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'ICE Book Mapping')

	BEGIN
		DECLARE @sub_book INT
		SELECT @sub_book=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Sub Book'

		UPDATE gmd
		SET 
			clm3_label = 'Sub Book',
			clm3_udf_id = @sub_book,
			clm4_label = NULL,
			clm4_udf_id = NULL
			FROM  generic_mapping_definition gmd
		INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
		WHERE  gmh.mapping_name = 'ICE Book Mapping'
	
		UPDATE gmv
		SET
			clm4_value = NULL
			FROM   generic_mapping_values gmv
		INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmv.mapping_table_id
		WHERE  gmh.mapping_name = 'ICE Book Mapping'

		UPDATE gmh SET gmh.total_columns_used = 3
		-- SELECT gmh.*
		FROM generic_mapping_header gmh
		WHERE gmh.mapping_name = 'ICE Book Mapping'
	END