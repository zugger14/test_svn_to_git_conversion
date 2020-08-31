DECLARE @ixp_table_id INT

SELECT @ixp_table_id = ixp_tables_id
FROM ixp_tables
WHERE ixp_tables_name = 'ixp_rec_inventory'

UPDATE ixp_columns
SET is_major = 1
WHERE ixp_table_id = @ixp_table_id 
	AND ixp_columns_name IN ('generator', 'vintage_month', 'vintage_year')
GO