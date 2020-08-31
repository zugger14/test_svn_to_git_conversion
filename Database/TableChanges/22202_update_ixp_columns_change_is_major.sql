DECLARE @ixp_table_id INT
SELECT @ixp_table_id = ixp_tables_id FROM ixp_tables where ixp_tables_name = 'ixp_storage_constraints_template'

UPDATE ixp_columns
SET is_major = 0
WHERE ixp_table_id = @ixp_table_id

UPDATE ixp_columns
SET is_major = 1
WHERE ixp_table_id = @ixp_table_id
	AND ixp_columns_name IN ('logical_name', 'constraint_type', 'effective_date')

GO