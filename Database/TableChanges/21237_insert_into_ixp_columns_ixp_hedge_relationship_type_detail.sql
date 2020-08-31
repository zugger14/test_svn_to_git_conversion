DECLARE @table_id INT 

SELECT @table_id = ixp_tables_id
FROM ixp_tables
WHERE ixp_tables_name = 'ixp_hedge_relationship_type_detail'

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @table_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype)
	VALUES(@table_id, 'sub_id', 'VARCHAR(6000)')

	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype)
	VALUES (@table_id, 'eff_test_name', 'VARCHAR(500)')

	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype)
	VALUES(@table_id, 'book_deal_type_map_id', 'VARCHAR(600)')

	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype)
	VALUES(@table_id, 'source_system_book_id1', 'VARCHAR(600)')

	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype)
	VALUES(@table_id, 'source_system_book_id2', 'VARCHAR(600)')

	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype)
	VALUES(@table_id, 'source_system_book_id3', 'VARCHAR(600)')

	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype)
	VALUES(@table_id, 'source_system_book_id4', 'VARCHAR(600)')

	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype)
	VALUES(@table_id, 'deal_xfer_source_book_id', 'VARCHAR(600)')

	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype)
	VALUES(@table_id, 'hedge_or_item', 'VARCHAR(600)')

	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype)
	VALUES(@table_id, 'buy_sell_flag', 'VARCHAR(600)')

	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype)
	VALUES(@table_id, 'fixed_float_flag', 'VARCHAR(600)')

	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype)
	VALUES(@table_id, 'eff_test_profile_detail_id', 'VARCHAR(600)')

	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype)
	VALUES(@table_id, 'eff_test_profile_id', 'VARCHAR(600)')

	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype)
	VALUES(@table_id, 'source_curve_def_id', 'VARCHAR(600)')

	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype)
	VALUES(@table_id, 'leg', 'VARCHAR(600)')

	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype)
	VALUES(@table_id, 'deal_sequence_number', 'VARCHAR(600)')

	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype)
	VALUES(@table_id, 'strip_month_from', 'VARCHAR(600)')

	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype)
	VALUES(@table_id, 'strip_month_to', 'VARCHAR(600)')

	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype)
	VALUES(@table_id, 'source_deal_type_id', 'VARCHAR(600)')

	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype)
	VALUES(@table_id, 'deal_sub_type_id', 'VARCHAR(600)')

	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype)
	VALUES(@table_id, 'volume_mix_percentage', 'VARCHAR(600)')

	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype)
	VALUES(@table_id, 'uom_conversion_factor', 'VARCHAR(600)')

	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype)
	VALUES(@table_id, 'price_adder', 'VARCHAR(600)')

	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype)
	VALUES(@table_id, 'price_multiplier', 'VARCHAR(600)')

	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype)
	VALUES(@table_id, 'strip_months', 'VARCHAR(600)')

	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype)
	VALUES(@table_id, 'strip_year_overlap', 'VARCHAR(600)')

	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype)
	VALUES(@table_id, 'roll_forward_year', 'VARCHAR(600)')

	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype)
	VALUES(@table_id, 'volume_round', 'VARCHAR(600)')

	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype)
	VALUES(@table_id, 'price_round', 'VARCHAR(600)')

END

GO