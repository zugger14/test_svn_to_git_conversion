DECLARE @ixp_table_id INT

IF NOT EXISTS (SELECT 1 FROM ixp_tables WHERE ixp_tables_name = 'ixp_shipper_code_deal_detail')
BEGIN
	INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)
	VALUES ('ixp_shipper_code_deal_detail', 'Shipper Code Deal Detail', 'i')
END

SELECT @ixp_table_id = ISNULL(ixp_tables_id, IDENT_CURRENT('ixp_tables')) 
FROM ixp_tables 
WHERE ixp_tables_name = 'ixp_shipper_code_deal_detail'

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'counterparty')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, is_required, seq)
	VALUES (@ixp_table_id, 'counterparty', 'NVARCHAR(600)', 0, 1, 10)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'contract')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, is_required, seq)
	VALUES (@ixp_table_id, 'contract', 'NVARCHAR(600)', 0, 1, 20)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'location')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, is_required, seq)
	VALUES (@ixp_table_id, 'location', 'NVARCHAR(600)', 0, 1, 30)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'deal_id')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, is_required, seq)
	VALUES (@ixp_table_id, 'deal_id', 'NVARCHAR(600)', 1, 1, 40)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'ext_deal_id')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, is_required, seq)
	VALUES (@ixp_table_id, 'ext_deal_id', 'NVARCHAR(600)', 0, 0, 50)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'term_start')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, is_required, seq, datatype)
	VALUES (@ixp_table_id, 'term_start', 'NVARCHAR(600)', 1, 1, 60, '[datetime]')
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'term_end')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, is_required, seq, datatype)
	VALUES (@ixp_table_id, 'term_end', 'NVARCHAR(600)', 1, 1, 70, '[datetime]')
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'shipper_code1')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, is_required, seq)
	VALUES (@ixp_table_id, 'shipper_code1', 'NVARCHAR(600)', 0, 1, 80)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'shipper_code2')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, is_required, seq)
	VALUES (@ixp_table_id, 'shipper_code2', 'NVARCHAR(600)', 0, 1, 90)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'leg')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, is_required, seq)
	VALUES (@ixp_table_id, 'leg', 'NVARCHAR(600)', 0, 0, 100)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'buy_sell')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, is_required, seq)
	VALUES (@ixp_table_id, 'buy_sell', 'NVARCHAR(600)', 0, 0, 110)
END