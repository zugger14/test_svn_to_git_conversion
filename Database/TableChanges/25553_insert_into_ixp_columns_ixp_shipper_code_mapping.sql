DECLARE @ixp_table_id INT

SELECT @ixp_table_id = ISNULL(ixp_tables_id, IDENT_CURRENT('ixp_tables')) 
FROM ixp_tables 
WHERE ixp_tables_name = 'ixp_shipper_code_mapping'

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'shipper_code1')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, seq, is_required)
	VALUES (@ixp_table_id, 'shipper_code1', 'NVARCHAR(600)', 35, 1)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'shipper_code1_is_default')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, seq, is_required)
	VALUES (@ixp_table_id, 'shipper_code1_is_default', 'NVARCHAR(600)', 45, 1)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'internal_counterparty_id')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, seq)
	VALUES (@ixp_table_id, 'internal_counterparty_id', 'NVARCHAR(600)', 80)
END
