
DECLARE @ixp_table VARCHAR(100) = 'ixp_source_deal_template', @ixp_tables_id INT
SELECT @ixp_tables_id = ixp_tables_id FROM ixp_tables AS it WHERE it.ixp_tables_name = @ixp_table

  
IF @ixp_tables_id IS NOT NULL AND NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_columns_name  = 'match_type' AND ic.ixp_table_id = @ixp_tables_id)
	INSERT INTO ixp_columns(ixp_table_id, ixp_columns_name, column_datatype, is_major, header_detail)
	SELECT @ixp_tables_id, 'match_type' , 'VARCHAR(600)', 0, 'h'     
 
IF @ixp_tables_id IS NOT NULL AND NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_columns_name  = 'product_classification' AND ic.ixp_table_id = @ixp_tables_id)
	INSERT INTO ixp_columns(ixp_table_id, ixp_columns_name, column_datatype, is_major, header_detail)
	SELECT @ixp_tables_id, 'product_classification' , 'VARCHAR(600)', 0, 'h'   

IF @ixp_tables_id IS NOT NULL AND NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_columns_name  = 'delivery_date' AND ic.ixp_table_id = @ixp_tables_id)
	INSERT INTO ixp_columns(ixp_table_id, ixp_columns_name, column_datatype, is_major, header_detail)
	SELECT @ixp_tables_id, 'delivery_date' , 'VARCHAR(600)', 0, 'd'   

