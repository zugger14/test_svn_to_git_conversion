
IF NOT EXISTS (SELECT 1 FROM ixp_ssis_configurations it WHERE it.package_name = 'weather') 
BEGIN
	 INSERT INTO ixp_ssis_configurations(package_name, package_description, config_filter_value)
	 SELECT 'weather', 'Weather Data Import', 'PRJ_Weather' 
END


IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_weather_template') 
BEGIN
	 INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)   
	 SELECT 'ixp_weather_template'  , 'Weather Data', 'i' 
END

INSERT INTO ixp_table_meta_data (ixp_tables_id, table_name)
SELECT it.ixp_tables_id,
       it.ixp_tables_name
FROM   ixp_tables it
LEFT JOIN ixp_table_meta_data itmd ON itmd.ixp_tables_id = it.ixp_tables_id
WHERE itmd.ixp_table_meta_data_table_id IS NULL

-- ixp_weather_template starts
DECLARE @ixp_weather_template_id INT	
SELECT @ixp_weather_template_id = it.ixp_tables_id FROM   ixp_tables it WHERE  it.ixp_tables_name = 'ixp_weather_template'

IF @ixp_weather_template_id IS NOT NULL
BEGIN

	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'stage_weather_id' AND ixp_table_id = @ixp_weather_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_weather_template_id, 'stage_weather_id', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'code' AND ixp_table_id = @ixp_weather_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_weather_template_id, 'code', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'o_f' AND ixp_table_id = @ixp_weather_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_weather_template_id, 'o_f', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'forecast_date' AND ixp_table_id = @ixp_weather_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_weather_template_id, 'forecast_date', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'tmp' AND ixp_table_id = @ixp_weather_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_weather_template_id, 'tmp', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'dpt' AND ixp_table_id = @ixp_weather_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_weather_template_id, 'dpt', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'hum' AND ixp_table_id = @ixp_weather_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_weather_template_id, 'hum', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'hid' AND ixp_table_id = @ixp_weather_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_weather_template_id, 'hid', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'wcl' AND ixp_table_id = @ixp_weather_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_weather_template_id, 'wcl', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'wdr' AND ixp_table_id = @ixp_weather_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_weather_template_id, 'wdr', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'wsp' AND ixp_table_id = @ixp_weather_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_weather_template_id, 'wsp', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'wet' AND ixp_table_id = @ixp_weather_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_weather_template_id, 'wet', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'cc' AND ixp_table_id = @ixp_weather_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_weather_template_id, 'cc', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'ssm' AND ixp_table_id = @ixp_weather_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_weather_template_id, 'ssm', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'published_date' AND ixp_table_id = @ixp_weather_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_weather_template_id, 'published_date', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'units' AND ixp_table_id = @ixp_weather_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_weather_template_id, 'units', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'filename' AND ixp_table_id = @ixp_weather_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_weather_template_id, 'filename', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'file_date' AND ixp_table_id = @ixp_weather_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_weather_template_id, 'file_date', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'create_ts' AND ixp_table_id = @ixp_weather_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_weather_template_id, 'create_ts', 0, NULL END
	
END
ELSE
BEGIN
	SELECT 'ixp_weather_template not present in ixp_tables'
END
-- ixp_weather_template END

--SELECT * FROM ixp_columns WHERE ixp_table_id = 2074

