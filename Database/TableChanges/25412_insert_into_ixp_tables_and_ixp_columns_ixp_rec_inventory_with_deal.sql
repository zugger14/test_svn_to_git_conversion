IF NOT EXISTS (SELECT 1 FROM ixp_tables WHERE ixp_tables_name = 'ixp_rec_inventory_deal_id')
BEGIN
	INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)
	VALUES ('ixp_rec_inventory_deal_id', 'Rec Inventory With Deal', 'i')
END

DECLARE @ixp_tables_id INT

SELECT @ixp_tables_id = ixp_tables_id
FROM ixp_tables
WHERE ixp_tables_name = 'ixp_rec_inventory_deal_id'

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'deal_id')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, seq, is_required)
	VALUES (@ixp_tables_id, 'deal_id', 'NVARCHAR(600)', 1, 10, 1)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'generator')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, seq, is_required)
	VALUES (@ixp_tables_id, 'generator', 'NVARCHAR(600)', 1, 20, 0)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'facility_name')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, seq, is_required)
	VALUES (@ixp_tables_id, 'facility_name', 'NVARCHAR(600)', 0, 30, 0)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'technology')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, seq, is_required)
	VALUES (@ixp_tables_id, 'technology', 'NVARCHAR(600)', 0, 40, 0)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'generation_state')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, seq, is_required)
	VALUES (@ixp_tables_id, 'generation_state', 'NVARCHAR(600)', 0, 50, 0)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'counterparty')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, seq, is_required)
	VALUES (@ixp_tables_id, 'counterparty', 'NVARCHAR(600)', 0, 60, 0)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'vintage_month')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, seq, is_required)
	VALUES (@ixp_tables_id, 'vintage_month', 'NVARCHAR(600)', 1, 70, 1)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'vintage_year')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, seq, is_required)
	VALUES (@ixp_tables_id, 'vintage_year', 'NVARCHAR(600)', 1, 80, 1)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'jurisdiction')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, seq, is_required)
	VALUES (@ixp_tables_id, 'jurisdiction', 'NVARCHAR(600)', 1, 90, 1)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'tier')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, seq, is_required)
	VALUES (@ixp_tables_id, 'tier', 'NVARCHAR(600)', 1, 100, 1)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'certificate_serial_numbers_from')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, seq, is_required)
	VALUES (@ixp_tables_id, 'certificate_serial_numbers_from', 'NVARCHAR(600)', 1, 110, 1)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'certificate_serial_numbers_to')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, seq, is_required)
	VALUES (@ixp_tables_id, 'certificate_serial_numbers_to', 'NVARCHAR(600)', 1, 120, 1)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'volume')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, seq, is_required)
	VALUES (@ixp_tables_id, 'volume', 'NVARCHAR(600)', 0, 130, 1)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'price')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, seq, is_required)
	VALUES (@ixp_tables_id, 'price', 'NVARCHAR(600)', 0, 140, 0)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'certificate_seq_from')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, seq, is_required)
	VALUES (@ixp_tables_id, 'certificate_seq_from', 'NVARCHAR(600)', 0, 150, 1)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'certificate_seq_to')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, seq, is_required)
	VALUES (@ixp_tables_id, 'certificate_seq_to', 'NVARCHAR(600)', 0, 160, 1)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'issue_date')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, seq, is_required)
	VALUES (@ixp_tables_id, 'issue_date', 'NVARCHAR(600)', 0, 170, 0)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'expiry_date')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, seq, is_required)
	VALUES (@ixp_tables_id, 'expiry_date', 'NVARCHAR(600)', 0, 180, 0)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'source_certificate_number')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, seq, is_required)
	VALUES (@ixp_tables_id, 'source_certificate_number', 'NVARCHAR(600)', 0, 190, 0)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'action')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, seq, is_required)
	VALUES (@ixp_tables_id, 'action', 'NVARCHAR(600)', 0, 200, 0)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'certification_entity')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, seq, is_required)
	VALUES (@ixp_tables_id, 'certification_entity', 'NVARCHAR(600)', 0, 200, 0)
END