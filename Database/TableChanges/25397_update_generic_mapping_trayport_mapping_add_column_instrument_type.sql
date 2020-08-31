DECLARE @udf_id INT

SELECT @udf_id = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_label = 'Instrument Name'

UPDATE gmd
SET clm3_label = 'Instrument Name'
	, clm3_udf_id = @udf_id
FROM generic_mapping_definition gmd
INNER JOIN generic_mapping_header gmh
	ON gmh.mapping_table_id =  gmd.mapping_table_id
WHERE gmh.mapping_name = 'Trayport Counterparty Mapping'
