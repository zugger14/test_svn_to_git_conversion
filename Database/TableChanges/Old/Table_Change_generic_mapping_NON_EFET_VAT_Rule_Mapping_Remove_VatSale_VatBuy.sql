IF EXISTS(SELECT 1 FROM generic_mapping_definition gmd INNER JOIN generic_mapping_header gmh ON gmd.mapping_table_id =	  	  gmh.mapping_table_id
			WHERE gmh.mapping_name = 'Non EFET VAT Rule Mapping' AND clm6_label = 'VAT Code Sale') 
BEGIN
		 UPDATE	 gmd SET clm6_label = 'VAT Code',
			 clm6_udf_id = ( SELECT udf_template_id
								   FROM   user_defined_fields_template
								   WHERE  Field_label = 'VAT Code')
			  FROM generic_mapping_definition gmd INNER JOIN generic_mapping_header gmh ON gmd.mapping_table_id = 
			  gmh.mapping_table_id
			  WHERE gmh.mapping_name = 'Non EFET VAT Rule Mapping'
END
ELSE 
	PRINT 'VAT CODE is already updated'

IF EXISTS(SELECT 1 FROM generic_mapping_definition gmd INNER JOIN generic_mapping_header gmh ON gmd.mapping_table_id =	  	  gmh.mapping_table_id
			WHERE gmh.mapping_name = 'Non EFET VAT Rule Mapping' AND clm8_label = 'VAT Code Buy')
BEGIN
		 UPDATE	 gmd SET clm8_label = (SELECT clm9_label FROM generic_mapping_definition gmd INNER JOIN generic_mapping_header gmh ON gmd.mapping_table_id =	  	  gmh.mapping_table_id
			WHERE gmh.mapping_name = 'Non EFET VAT Rule Mapping'),
			 clm8_udf_id = ( SELECT clm9_udf_id FROM generic_mapping_definition gmd INNER JOIN generic_mapping_header gmh ON gmd.mapping_table_id =	  	  gmh.mapping_table_id
			WHERE gmh.mapping_name = 'Non EFET VAT Rule Mapping'),
			clm9_label = NULL,
			clm9_udf_id = NULL

			  FROM generic_mapping_definition gmd INNER JOIN generic_mapping_header gmh ON gmd.mapping_table_id = 
			  gmh.mapping_table_id
			  WHERE gmh.mapping_name = 'Non EFET VAT Rule Mapping'
END
IF EXISTS(SELECT 1 FROM generic_mapping_definition gmd INNER JOIN generic_mapping_header gmh ON gmd.mapping_table_id =	  	  gmh.mapping_table_id
			WHERE gmh.mapping_name = 'Non EFET VAT Rule Mapping' AND clm7_label = 'VAT GL Account Sale')
BEGIN
	 UPDATE	 gmd SET clm7_label = 'VAT GL Account'
			  FROM generic_mapping_definition gmd INNER JOIN generic_mapping_header gmh ON gmd.mapping_table_id = 
			  gmh.mapping_table_id
			  WHERE gmh.mapping_name = 'Non EFET VAT Rule Mapping'

		UPDATE user_defined_fields_template SET 
		field_label = 'VAT GL Account'
		WHERE field_label = 'VAT GL Account Sale'

END
ELSE
	PRINT 'VAT GL Account already renamed'
	
	IF EXISTS(SELECT 1 FROM generic_mapping_definition gmd INNER JOIN generic_mapping_header gmh ON gmd.mapping_table_id =	  	  gmh.mapping_table_id
			WHERE gmh.mapping_name = 'Non EFET VAT Rule Mapping' AND clm9_label = 'VAT GL Account Buy')
BEGIN
			UPDATE	 gmd SET
				clm9_label = NULL

			  FROM generic_mapping_definition gmd INNER JOIN generic_mapping_header gmh ON gmd.mapping_table_id = 
			  gmh.mapping_table_id
			  WHERE gmh.mapping_name = 'Non EFET VAT Rule Mapping'
END	
		
			
		 