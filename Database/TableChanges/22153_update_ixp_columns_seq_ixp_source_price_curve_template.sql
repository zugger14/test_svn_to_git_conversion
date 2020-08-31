DECLARE @ixp_table_id INT
SELECT @ixp_table_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_source_price_curve_template'

UPDATE ixp_columns
SET seq = 70
WHERE ixp_columns_name = 'bid_value' AND ixp_table_id = @ixp_table_id

UPDATE ixp_columns
SET seq = 80
WHERE ixp_columns_name = 'ask_value' AND ixp_table_id = @ixp_table_id

UPDATE ixp_columns
SET seq = 90
WHERE ixp_columns_name = 'curve_value' AND ixp_table_id = @ixp_table_id

UPDATE ixp_columns
SET seq = 100
WHERE ixp_columns_name = 'is_dst' AND ixp_table_id = @ixp_table_id

GO