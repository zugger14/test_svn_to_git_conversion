DECLARE @ixp_table_id INT

IF NOT EXISTS (SELECT 1 FROM ixp_tables WHERE ixp_tables_name = 'ixp_shipper_code_mapping')
BEGIN
	INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)
	VALUES ('ixp_shipper_code_mapping', 'Shipper Code Mapping', 'i')
END

SELECT @ixp_table_id = ISNULL(ixp_tables_id, IDENT_CURRENT('ixp_tables')) 
FROM ixp_tables 
WHERE ixp_tables_name = 'ixp_shipper_code_mapping'

IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'effective_date')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, is_required, seq, datatype)
	VALUES (@ixp_table_id, 'effective_date', 'VARCHAR(600)', 1, 1, 10, '[datetime]')
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'counterparty')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, is_required, seq)
	VALUES (@ixp_table_id, 'counterparty', 'VARCHAR(600)', 1, 1, 20)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'location')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, is_required, seq)
	VALUES (@ixp_table_id, 'location', 'VARCHAR(600)', 1, 1, 30)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'shipper_code')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, seq)
	VALUES (@ixp_table_id, 'shipper_code', 'VARCHAR(600)', 40)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'is_default')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, seq)
	VALUES (@ixp_table_id, 'is_default', 'VARCHAR(600)', 50)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'is_active')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, seq)
	VALUES (@ixp_table_id, 'is_active', 'VARCHAR(600)', 60)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'external_id')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, seq)
	VALUES (@ixp_table_id, 'external_id', 'VARCHAR(600)', 70)
END