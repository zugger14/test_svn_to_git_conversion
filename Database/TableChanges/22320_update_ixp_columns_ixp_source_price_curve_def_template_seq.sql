DECLARE @ixp_table_id INT
SELECT @ixp_table_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_source_price_curve_def_template'
 
-- Update seq
UPDATE ixp_columns 
SET seq = 91 
WHERE ixp_columns_name = 'index_group'
	AND ixp_table_id = @ixp_table_id


