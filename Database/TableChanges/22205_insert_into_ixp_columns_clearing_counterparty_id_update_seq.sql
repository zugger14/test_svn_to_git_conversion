DECLARE @ixp_tables_id INT
SELECT @ixp_tables_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_source_deal_template'
 
-- insert into ixp_columns
IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = 14 and ic.ixp_columns_name = 'clearing_counterparty_id')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, is_required, header_detail, seq) 
	VALUES
	(@ixp_tables_id,'clearing_counterparty_id',  0, 0, 'h', 800)
END

-- update sequence
UPDATE ixp_columns SET seq = 770 WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'timezone_id'
UPDATE ixp_columns SET seq = 780 WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'deal_category_value_id'
UPDATE ixp_columns SET seq = 790 WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'buy_sell_flag'
UPDATE ixp_columns SET seq = 800 WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'fixed_float_leg'
UPDATE ixp_columns SET seq = 810 WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'udf_value1'
UPDATE ixp_columns SET seq = 820 WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'udf_value2'
UPDATE ixp_columns SET seq = 830 WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'udf_value3'
UPDATE ixp_columns SET seq = 840 WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'clearing_counterparty_id'
UPDATE ixp_columns SET seq = 850 WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'udf_value4'