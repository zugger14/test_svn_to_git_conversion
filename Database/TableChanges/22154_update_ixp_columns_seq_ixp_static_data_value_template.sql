DECLARE @ixp_table_id INT
SELECT @ixp_table_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_static_data_value_template'

UPDATE ixp_columns
SET seq = 10
WHERE ixp_columns_name = 'type_id' AND ixp_table_id = @ixp_table_id

UPDATE ixp_columns
SET seq = 20
WHERE ixp_columns_name = 'code' AND ixp_table_id = @ixp_table_id

UPDATE ixp_columns
SET seq = 30
WHERE ixp_columns_name = 'description' AND ixp_table_id = @ixp_table_id