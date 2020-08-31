
DECLARE @ixp_table VARCHAR(100) = 'ixp_source_deal_template', @ixp_tables_id INT
SELECT @ixp_tables_id = ixp_tables_id FROM ixp_tables AS it WHERE it.ixp_tables_name = @ixp_table

IF @ixp_tables_id IS NOT NULL AND NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_columns_name  = 'counterparty_id2' AND ic.ixp_table_id = @ixp_tables_id)
	INSERT INTO ixp_columns(ixp_table_id, ixp_columns_name, column_datatype, is_major, header_detail)
	SELECT @ixp_tables_id, 'counterparty_id2' , 'VARCHAR(600)', 0, 'h'        

IF @ixp_tables_id IS NOT NULL AND NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_columns_name  = 'trader_id2' AND ic.ixp_table_id = @ixp_tables_id)
	INSERT INTO ixp_columns(ixp_table_id, ixp_columns_name, column_datatype, is_major, header_detail)
	SELECT @ixp_tables_id, 'trader_id2' , 'VARCHAR(600)', 0, 'h'      
 
 
IF @ixp_tables_id IS NOT NULL AND NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_columns_name  = 'actual_volume' AND ic.ixp_table_id = @ixp_tables_id)
	INSERT INTO ixp_columns(ixp_table_id, ixp_columns_name, column_datatype, is_major, header_detail)
	SELECT @ixp_tables_id, 'actual_volume' , 'VARCHAR(600)', 0, 'd'      
 
 
IF @ixp_tables_id IS NOT NULL AND NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_columns_name  = 'schedule_volume' AND ic.ixp_table_id = @ixp_tables_id)
	INSERT INTO ixp_columns(ixp_table_id, ixp_columns_name, column_datatype, is_major, header_detail)
	SELECT @ixp_tables_id, 'schedule_volume' , 'VARCHAR(600)', 0, 'd'      
 
 
-- IF @ixp_tables_id IS NOT NULL AND NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_columns_name  = 'deal_seperator_id' AND ic.ixp_table_id = @ixp_tables_id)
--	INSERT INTO ixp_columns(ixp_table_id, ixp_columns_name, column_datatype, is_major, header_detail)
--	SELECT @ixp_tables_id, 'deal_seperator_id' , 'VARCHAR(600)', 0, 'h'      
 
 
-- IF @ixp_tables_id IS NOT NULL AND NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_columns_name  = 'Intrabook_deal_flag' AND ic.ixp_table_id = @ixp_tables_id)
--	INSERT INTO ixp_columns(ixp_table_id, ixp_columns_name, column_datatype, is_major, header_detail)
--	SELECT @ixp_tables_id, 'Intrabook_deal_flag' , 'VARCHAR(600)', 0, 'h'      
 
 