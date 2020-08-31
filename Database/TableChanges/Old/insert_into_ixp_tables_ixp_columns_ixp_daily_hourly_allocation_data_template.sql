IF NOT EXISTS (
       SELECT 1
       FROM   ixp_tables it
       WHERE  it.ixp_tables_name = 'ixp_daily_hourly_allocation_data_template'
   )
BEGIN
    INSERT INTO ixp_tables
      (
        ixp_tables_name,
        ixp_tables_description,
        import_export_flag
      )
    SELECT 'ixp_daily_hourly_allocation_data_template',
           'Allocation Data (Daily-Hourly)',
           'i'
END

DECLARE @ixp_daily_hourly_allocation_data_template_id INT	
SELECT @ixp_daily_hourly_allocation_data_template_id = it.ixp_tables_id FROM   ixp_tables it WHERE  it.ixp_tables_name = 'ixp_daily_hourly_allocation_data_template'

IF @ixp_daily_hourly_allocation_data_template_id IS NOT NULL
BEGIN
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'end_date' AND ixp_table_id = @ixp_daily_hourly_allocation_data_template_id) 
	BEGIN 
		INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) 
		SELECT @ixp_daily_hourly_allocation_data_template_id, 'end_date', 0, NULL 
	END
	
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'channel' AND ixp_table_id = @ixp_daily_hourly_allocation_data_template_id) 
	BEGIN 
		INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) 
		SELECT @ixp_daily_hourly_allocation_data_template_id, 'channel', 0, NULL 
	END
	
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'date' AND ixp_table_id = @ixp_daily_hourly_allocation_data_template_id) 
	BEGIN 
		INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) 
		SELECT @ixp_daily_hourly_allocation_data_template_id, 'date', 0, NULL 
	END
	
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'hour' AND ixp_table_id = @ixp_daily_hourly_allocation_data_template_id) 
	BEGIN 
		INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) 
		SELECT @ixp_daily_hourly_allocation_data_template_id, 'hour', 0, NULL 
	END
	
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'meter_id' AND ixp_table_id = @ixp_daily_hourly_allocation_data_template_id) 
	BEGIN 
		INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) 
		SELECT @ixp_daily_hourly_allocation_data_template_id, 'meter_id', 0, NULL 
	END
	
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'value' AND ixp_table_id = @ixp_daily_hourly_allocation_data_template_id) 
	BEGIN 
		INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) 
		SELECT @ixp_daily_hourly_allocation_data_template_id, 'value', 0, NULL 
	END
	
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'period' AND ixp_table_id = @ixp_daily_hourly_allocation_data_template_id) 
	BEGIN 
		INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) 
		SELECT @ixp_daily_hourly_allocation_data_template_id, 'period', 0, NULL 
	END
END
