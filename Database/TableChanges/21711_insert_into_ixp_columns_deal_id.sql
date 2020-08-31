DECLARE @ixp_table_id INT 
SELECT @ixp_table_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_counterparty_credit_enhancements_template'  
IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id and ixp_columns_name = 'deal_id')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,header_detail)
	SELECT @ixp_table_id, 'deal_id', 'VARCHAR(200)', 0 ,NULL
END