/**
	Update query value for generic mapping ''Storage Book Mapping'' column second : BIC
*/
DECLARE @clm2_udf_id INT

SELECT @clm2_udf_id = clm2_udf_id
FROM generic_mapping_header gmh
INNER JOIN generic_mapping_definition gmd ON gmd.mapping_table_id = gmh.mapping_table_id
WHERE gmh.mapping_name = 'Storage Book Mapping'

UPDATE user_defined_fields_template
SET sql_string = 'SELECT ''w'' [value], ''Withdrawl'' [label] UNION ALL SELECT ''i'', ''Injection'' UNION ALL SELECT ''n'', ''Inventory'''
WHERE udf_template_id = @clm2_udf_id

GO