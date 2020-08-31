DECLARE @udf_template_id INT

SELECT @udf_template_id = udf_template_id
FROM   user_defined_fields_template
WHERE  Field_label = 'No of Days'
       
UPDATE gmd
SET    clm3_udf_id = @udf_template_id
FROM   generic_mapping_definition gmd
       INNER JOIN generic_mapping_header gmh
            ON  gmh.mapping_table_id = gmd.mapping_table_id
            AND gmh.mapping_name = 'Data Enhancement Rule'