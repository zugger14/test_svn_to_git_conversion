IF NOT EXISTS (SELECT 1 FROM ixp_tables WHERE ixp_tables_name = 'ixp_counterparty_bank_info')
BEGIN
	INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)
	VALUES ('ixp_counterparty_bank_info', 'Counterparty Bank Information', 'i')
END

DECLARE @ixp_tables_id INT

SELECT @ixp_tables_id = ixp_tables_id
FROM ixp_tables
WHERE ixp_tables_name = 'ixp_counterparty_bank_info'

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'counterparty_id')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, seq, is_required)
	VALUES (@ixp_tables_id, 'counterparty_id', 'VARCHAR(600)', 1, 10, 1)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'bank_name')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, seq, is_required)
	VALUES (@ixp_tables_id, 'bank_name', 'VARCHAR(600)', 0, 20, 1)
END
	  
IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'account_name')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, seq, is_required)
	VALUES (@ixp_tables_id, 'account_name', 'VARCHAR(600)', 1, 30, 1)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'Account_no')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, seq, is_required)
	VALUES (@ixp_tables_id, 'Account_no', 'VARCHAR(600)', 1, 40, 1)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'ACH_ABA')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, seq, is_required)
	VALUES (@ixp_tables_id, 'ACH_ABA', 'VARCHAR(600)', 0, 50, 0)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'wire_ABA')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, seq, is_required)
	VALUES (@ixp_tables_id, 'wire_ABA', 'VARCHAR(600)', 0, 60, 0)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'currency')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, seq, is_required)
	VALUES (@ixp_tables_id, 'currency', 'VARCHAR(600)', 0, 70, 1)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'Address1')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, seq, is_required)
	VALUES (@ixp_tables_id, 'Address1', 'VARCHAR(600)', 0, 80, 0)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'Address2')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, seq, is_required)
	VALUES (@ixp_tables_id, 'Address2', 'VARCHAR(600)', 0, 90, 0)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'reference')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, seq, is_required)
	VALUES (@ixp_tables_id, 'reference', 'VARCHAR(600)', 0, 100, 0)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'primary_account')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, seq, is_required)
	VALUES (@ixp_tables_id, 'primary_account', 'VARCHAR(600)', 0, 110, 0)
END