IF EXISTS (SELECT 1 FROM generic_mapping_header AS gmv 
   INNER JOIN generic_mapping_definition gmd ON gmd.mapping_table_id = gmv.mapping_table_id
   WHERE gmv.mapping_name IN ('SAP GL Code Mapping','VAT Rule Mapping','Invoice Title','Contract Meters','Contract Curves','Contract Values')
    AND gmd.generic_mapping_definition_id IS NULL
    )
BEGIN
  DELETE FROM generic_mapping_header
  WHERE mapping_name IN ('SAP GL Code Mapping','VAT Rule Mapping','Invoice Title','Contract Meters','Contract Curves','Contract Values')
END




	
	
	
	
