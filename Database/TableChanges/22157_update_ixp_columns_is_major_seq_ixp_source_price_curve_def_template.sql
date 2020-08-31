DECLARE @ixp_table_id INT

SELECT @ixp_table_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_source_price_curve_def_template'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'curve_tou')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, seq, is_required)
	VALUES (@ixp_table_id, 'curve_tou', 'VARCHAR(800)', 0, 80, 0)
END

UPDATE ixp_columns
SET is_major = 0, is_required = 0
WHERE ixp_table_id = @ixp_table_id

UPDATE ixp_columns
SET is_required = 1
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name IN ('curve_id', 'curve_name', 'source_curve_type_value_id', 'Granularity', 'source_currency_id', 'uom_id', 'commodity_id')

UPDATE ixp_columns
SET is_major = 1
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'curve_id'

UPDATE ixp_columns
SET seq = 30
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'curve_des'

UPDATE ixp_columns
SET seq = 40
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'source_curve_type_value_id'

UPDATE ixp_columns
SET seq = 50
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Granularity'

UPDATE ixp_columns
SET seq = 60
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'source_currency_id'

UPDATE ixp_columns
SET seq = 70
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'source_currency_to_id'

UPDATE ixp_columns
SET seq = 80
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'uom_id'

UPDATE ixp_columns
SET seq = 90
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'commodity_id'

UPDATE ixp_columns
SET seq = 100
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'market_value_desc'

UPDATE ixp_columns
SET seq = 110
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'market_value_id'

UPDATE ixp_columns
SET seq = 120
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'liquidation_multiplier'

UPDATE ixp_columns
SET seq = 130
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'effective_date'

UPDATE ixp_columns
SET seq = 140
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'curve_tou'

UPDATE ixp_columns
SET seq = 150
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'udf_block_group_id'

UPDATE ixp_columns
SET seq = 160
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'block_define_id'

UPDATE ixp_columns
SET seq = 170
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'exp_calendar_id'

UPDATE ixp_columns
SET seq = 180
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'holiday_calendar_id'

UPDATE ixp_columns
SET seq = 190
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'time_zone'

UPDATE ixp_columns
SET seq = 200
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'obligation'

UPDATE ixp_columns
SET seq = 210
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Forward_Settle'

UPDATE ixp_columns
SET seq = 220
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'curve_definition'

UPDATE ixp_columns
SET seq = 230
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'rtc_curve_1'

UPDATE ixp_columns
SET seq = 240
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'rtc_curve_2'

UPDATE ixp_columns
SET seq = 250
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'rtc_curve_3'

UPDATE ixp_columns
SET seq = 260
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'rtc_curve_4'

UPDATE ixp_columns
SET seq = 270
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'proxy_curve_id'

UPDATE ixp_columns
SET seq = 280
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'display_uom_id'

UPDATE ixp_columns
SET seq = 290
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'hourly_volume_allocation'

UPDATE ixp_columns
SET seq = 300
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'proxy_source_curve_def_id'

UPDATE ixp_columns
SET seq = 310
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'monthly_index'

UPDATE ixp_columns
SET seq = 320
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'proxy_curve_id3'

UPDATE ixp_columns
SET seq = 330
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'settlement_curve_id'

GO