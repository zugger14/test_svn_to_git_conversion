DECLARE @ixp_table_id INT
SELECT @ixp_table_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_delivery_path_template'

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'group_path_code' AND ixp_table_id = @ixp_table_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	SELECT @ixp_table_id, 'group_path_code', 'VARCHAR(600)', 0
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'path_sequence' AND ixp_table_id = @ixp_table_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	SELECT @ixp_table_id, 'path_sequence', 'VARCHAR(600)', 0
END