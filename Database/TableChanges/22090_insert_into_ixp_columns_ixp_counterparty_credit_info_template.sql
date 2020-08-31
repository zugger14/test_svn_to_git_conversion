DECLARE @ixp_table_id INT

SELECT @ixp_table_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_counterparty_credit_info_template'

-- Buy Notional Month
IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'buy_notional_month')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,header_detail)
	SELECT @ixp_table_id, 'buy_notional_month', 'VARCHAR(1000)', 0 ,NULL
END

-- Sell Notional Month
IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'sell_notional_month')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,header_detail)
	SELECT @ixp_table_id, 'sell_notional_month', 'VARCHAR(1000)', 0 ,NULL
END

GO