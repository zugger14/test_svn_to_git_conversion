DECLARE @ixp_table_id INT

SELECT @ixp_table_id = ixp_tables_id 
FROM ixp_tables
WHERE ixp_tables_name = 'ixp_source_deal_detail_15min_template'

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'schedule_volume')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_table_id, 'schedule_volume', 'VARCHAR(600)', 0)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'actual_volume')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_table_id, 'actual_volume', 'VARCHAR(600)', 0)
END