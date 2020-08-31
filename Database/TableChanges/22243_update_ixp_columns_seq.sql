DECLARE @ixp_table_id INT
SELECT @ixp_table_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_storage_ratchet'

UPDATE ixp_columns SET seq = 10 WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'general_assest_id'
UPDATE ixp_columns SET seq = 20 WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'term_from'
UPDATE ixp_columns SET seq = 30 WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'term_to'
UPDATE ixp_columns SET seq = 40 WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'inventory_level_from'
UPDATE ixp_columns SET seq = 50 WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'inventory_level_to'
UPDATE ixp_columns SET seq = 60 WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'gas_in_storage_perc_from'
UPDATE ixp_columns SET seq = 70 WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'gas_in_storage_perc_to'
UPDATE ixp_columns SET seq = 80 WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'type'
UPDATE ixp_columns SET seq = 90 WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'perc_of_contracted_storage_space'
UPDATE ixp_columns SET seq = 100 WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'fixed_value'
