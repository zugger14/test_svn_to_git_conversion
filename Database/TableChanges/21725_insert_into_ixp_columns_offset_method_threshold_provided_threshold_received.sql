DECLARE @ixp_table_id INT
SELECT @ixp_table_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_counterparty_contract_address_template'  
--select @ixp_table_id
IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_table_id = @ixp_table_id and ixp_columns_name = 'offset_method')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,header_detail)
	SELECT @ixp_table_id, 'offset_method', 'VARCHAR(200)', 0 ,NULL
END
 
IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id and ixp_columns_name = 'threshold_provided')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,header_detail)
	SELECT @ixp_table_id, 'threshold_provided', 'float', 0 ,NULL
END
 
IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id and ixp_columns_name = 'threshold_received ')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,header_detail)
	SELECT @ixp_table_id, 'threshold_received', 'float', 0 ,NULL
END
