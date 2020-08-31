DECLARE @source_instrument INT

SELECT @source_instrument = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_label = 'Source Instrument'

UPDATE gmd
SET clm1_udf_id = @source_instrument
FROM generic_mapping_definition gmd
INNER JOIN generic_mapping_header gmh 
	ON gmh.mapping_table_id = gmd.mapping_table_id
WHERE gmh.mapping_name = 'Trayport Block Mapping'