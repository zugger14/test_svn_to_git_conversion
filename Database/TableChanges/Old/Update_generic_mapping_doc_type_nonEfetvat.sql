IF NOT EXISTS(SELECT 1 FROM generic_mapping_definition gmd INNER JOIN generic_mapping_header gmh ON gmd.mapping_table_id =  gmh.mapping_table_id
			WHERE gmh.mapping_name = 'Non EFET VAT Rule Mapping' AND clm6_label = 'Doc Type') 
BEGIN
		 UPDATE	 gmd SET clm8_label = 'Doc Type',
			 clm8_udf_id = ( SELECT udf_template_id
								   FROM   user_defined_fields_template
								   WHERE  Field_label = 'Doc Type')
			  FROM generic_mapping_definition gmd INNER JOIN generic_mapping_header gmh ON gmd.mapping_table_id = 
			  gmh.mapping_table_id
			  WHERE gmh.mapping_name = 'Non EFET VAT Rule Mapping'
END
ELSE 
	PRINT 'Doc Type is already updated'

	UPDATE gmd SET gmd.unique_columns_index = '1,2,3,4,8' FROM  generic_mapping_definition gmd INNER JOIN generic_mapping_header gmh ON gmd.mapping_table_id = 
			  gmh.mapping_table_id
			  WHERE gmh.mapping_name = 'Non EFET VAT Rule Mapping'
	