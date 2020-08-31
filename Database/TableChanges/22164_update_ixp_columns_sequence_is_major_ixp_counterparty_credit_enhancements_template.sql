DECLARE @ixp_table_id INT

SELECT @ixp_table_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_counterparty_credit_enhancements_template'

UPDATE ixp_columns
SET is_major = 0
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'exclude_collateral'

UPDATE ixp_columns
SET seq = 70
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'collateral_status'

UPDATE ixp_columns
SET seq = 140
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'auto_renewal'

UPDATE ixp_columns
SET seq = 150
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'blocked'

UPDATE ixp_columns
SET seq = 160
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'transferred'

UPDATE ixp_columns
SET seq = 170
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'is_primary'

UPDATE ixp_columns
SET seq = 180
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'comment'

UPDATE ixp_columns
SET seq = 190
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'approved_by'

GO