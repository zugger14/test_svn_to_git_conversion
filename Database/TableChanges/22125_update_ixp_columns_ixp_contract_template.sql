DECLARE @ixp_table_id INT
SELECT @ixp_table_id = ixp_tables_id from ixp_tables WHERE ixp_tables_name = 'ixp_contract_template'

-- Update sequence
UPDATE ic SET seq = 320 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'storage_asset_id'
UPDATE ic SET seq = 330 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'pipeline'