DECLARE @ixp_table_id INT
SELECT @ixp_table_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_source_deal_template'  
--select @ixp_table_id
IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_table_id = @ixp_table_id and ixp_columns_name = 'fas_deal_type_value_id')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,header_detail)
	SELECT @ixp_table_id, 'fas_deal_type_value_id', 'VARCHAR(600)', 0 ,NULL
END



 