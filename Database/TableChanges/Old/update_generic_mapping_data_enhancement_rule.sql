-- Meter ID column unique and required
UPDATE gmd SET  gmd.unique_columns_index = '1',
       gmd.required_columns_index = '1'
FROM   generic_mapping_header gmh
       INNER JOIN generic_mapping_definition gmd
            ON  gmh.mapping_table_id = gmd.mapping_table_id
WHERE  gmh.mapping_name = 'Data Enhancement Rule'