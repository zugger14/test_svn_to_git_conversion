IF (SELECT 1 FROM ixp_tables WHERE ixp_tables_name = 'ixp_location_group_template') IS NULL
BEGIN
	INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)
	VALUES ('ixp_location_group_template', 'Location Group', 'i')
END

DECLARE @ixp_table_id INT
SELECT @ixp_table_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_location_group_template'  
IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id and ixp_columns_name = 'source_system_id')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,header_detail)
	SELECT @ixp_table_id, 'source_system_id', 'VARCHAR(600)', 0 ,NULL
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id and ixp_columns_name = 'location_name')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,header_detail)
	SELECT @ixp_table_id, 'location_name', 'VARCHAR(600)', 0 ,NULL
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id and ixp_columns_name = 'location_description')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,header_detail)
	SELECT @ixp_table_id, 'location_description', 'VARCHAR(600)', 0 ,NULL
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id and ixp_columns_name = 'location_type')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,header_detail)
	SELECT @ixp_table_id, 'location_type', 'VARCHAR(600)', 0 ,NULL
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id and ixp_columns_name = 'region')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,header_detail)
	SELECT @ixp_table_id, 'region', 'VARCHAR(600)', 0 ,NULL
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id and ixp_columns_name = 'owner')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,header_detail)
	SELECT @ixp_table_id, 'owner', 'VARCHAR(600)', 0 ,NULL
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id and ixp_columns_name = 'operator')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,header_detail)
	SELECT @ixp_table_id, 'operator', 'VARCHAR(600)', 0 ,NULL
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id and ixp_columns_name = 'counterparty')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,header_detail)
	SELECT @ixp_table_id, 'counterparty', 'VARCHAR(600)', 0 ,NULL
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id and ixp_columns_name = 'contract')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,header_detail)
	SELECT @ixp_table_id, 'contract', 'VARCHAR(600)', 0 ,NULL
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id and ixp_columns_name = 'volume')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,header_detail)
	SELECT @ixp_table_id, 'volume', 'VARCHAR(600)', 0 ,NULL
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id and ixp_columns_name = 'uom')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,header_detail)
	SELECT @ixp_table_id, 'uom', 'VARCHAR(600)', 0 ,NULL
END
GO