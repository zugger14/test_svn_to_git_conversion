DECLARE @ixp_table_id INT

SELECT @ixp_table_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_counterparty_credit_enhancements_template'

-- Collateral Status
IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'collateral_status')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,header_detail)
	SELECT @ixp_table_id, 'collateral_status', 'VARCHAR(100)', 0 ,NULL
END

-- Primary
IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'is_primary')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,header_detail)
	SELECT @ixp_table_id, 'is_primary', 'VARCHAR(50)', 0 ,NULL
END

-- Transfer
IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'transferred')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,header_detail)
	SELECT @ixp_table_id, 'transferred', 'VARCHAR(50)', 0 ,NULL
END

-- Blocked
IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'blocked')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,header_detail)
	SELECT @ixp_table_id, 'blocked', 'VARCHAR(50)', 0 ,NULL
END

-- Auto Renewal
IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'auto_renewal')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,header_detail)
	SELECT @ixp_table_id, 'auto_renewal', 'VARCHAR(50)', 0 ,NULL
END

GO