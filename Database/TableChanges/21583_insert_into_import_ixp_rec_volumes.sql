DECLARE @ixp_table_id INT

IF NOT EXISTS(SELECT 1 FROM ixp_tables WHERE ixp_tables_name = 'ixp_rec_volumes')
BEGIN
	INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)
	VALUES ('ixp_rec_volumes', 'Import REC Volumes', 'i')
END

SELECT @ixp_table_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_rec_volumes'
SET @ixp_table_id = ISNULL(@ixp_table_id, IDENT_CURRENT('ixp_tables'))

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'deal_id')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_table_id, 'deal_id', 'VARCHAR(600)', 0)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'vintage_start')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_table_id, 'vintage_start', 'VARCHAR(600)', 0)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'forecast_volume')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_table_id, 'forecast_volume', 'VARCHAR(600)', 0)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'actual_volume')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_table_id, 'actual_volume', 'VARCHAR(600)', 0)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'certified_volume')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_table_id, 'certified_volume', 'VARCHAR(600)', 0)
END