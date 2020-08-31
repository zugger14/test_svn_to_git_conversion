
UPDATE user_defined_fields_template
SET    Field_label = 'Inbound Outbound'
WHERE  udf_template_id = 201

DECLARE @mapping_table_id INT
SELECT @mapping_table_id = mapping_table_id
FROM   generic_mapping_header
WHERE  mapping_name = 'Non EFET SAP Doc Type'

UPDATE generic_mapping_definition
SET    clm2_udf_id   = 210
WHERE  mapping_table_id = @mapping_table_id