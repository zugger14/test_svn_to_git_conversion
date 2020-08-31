DECLARE @ixp_table_id INT
SELECT @ixp_table_id = ixp_tables_id 
from ixp_tables where ixp_tables_name = 'ixp_source_counterparty_template'

UPDATE ic SET seq = 10 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'counterparty_id'
UPDATE ic SET seq = 20 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'counterparty_name'
UPDATE ic SET seq = 30 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'counterparty_desc'
UPDATE ic SET seq = 40 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'parent_counterparty_id'
UPDATE ic SET seq = 50 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'int_ext_flag'
UPDATE ic SET seq = 60 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'type_of_entity'
UPDATE ic SET seq = 70 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'analyst'
UPDATE ic SET seq = 80 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'counterparty_status'
UPDATE ic SET seq = 90 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'is_active'
UPDATE ic SET seq = 100 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'counterparty_contact_notes'
UPDATE ic SET seq = 110 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'delivery_method'