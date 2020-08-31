DECLARE @ixp_table_id INT

SELECT @ixp_table_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_counterparty_credit_limits_template'

-- Limit Status
IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'limit_status')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,header_detail)
	SELECT @ixp_table_id, 'limit_status', 'VARCHAR(800)', 0 ,NULL
END

GO