DECLARE @ixp_table_id INT
SELECT @ixp_table_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_source_deal_template'

UPDATE ixp_columns
SET seq = 105
WHERE ixp_columns_name = 'deal_sub_type_type_id' AND ixp_table_id = @ixp_table_id