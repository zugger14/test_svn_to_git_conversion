DECLARE @ixp_tables_id INT = NULL
SELECT @ixp_tables_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_storage_asset_group_info'

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'asset_name')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, header_detail)
	VALUES (@ixp_tables_id, 'asset_name', 'VARCHAR(300)', 0, NULL)
END
IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'asset_description')
BEGIN	
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, header_detail)
	VALUES (@ixp_tables_id, 'asset_description', 'VARCHAR(300)', 0, NULL)
END
IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'commodity_id')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, header_detail)
	VALUES (@ixp_tables_id, 'commodity_id', 'VARCHAR(40)', 0, NULL)
END
IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'location_id')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, header_detail)
	VALUES (@ixp_tables_id, 'location_id', 'VARCHAR(40)', 0, NULL)
END
IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'counterparty_effective_date')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, header_detail)
	VALUES (@ixp_tables_id, 'counterparty_effective_date', 'VARCHAR(30)', 0, NULL)
END
IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'counterparty_id')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, header_detail)
	VALUES (@ixp_tables_id, 'counterparty_id', 'VARCHAR(40)', 0, NULL)
END
IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'percentage')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, header_detail)
	VALUES (@ixp_tables_id, 'percentage', 'VARCHAR(50)', 0, NULL)
END
IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'reservoir_effective_date')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, header_detail)
	VALUES (@ixp_tables_id, 'reservoir_effective_date', 'VARCHAR(30)', 0, NULL)
END
IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'reservoir')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, header_detail)
	VALUES (@ixp_tables_id, 'reservoir', 'VARCHAR(300)', 0, NULL)
END
IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'reservoir_type')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, header_detail)
	VALUES (@ixp_tables_id, 'reservoir_type', 'VARCHAR(300)', 0, NULL)
END
IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'capacity')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, header_detail)
	VALUES (@ixp_tables_id, 'capacity', 'VARCHAR(50)', 0, NULL)
END
IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'uom')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, header_detail)
	VALUES (@ixp_tables_id, 'uom', 'VARCHAR(40)', 0, NULL)
END

GO