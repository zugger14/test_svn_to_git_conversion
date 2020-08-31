IF NOT EXISTS(SELECT 1 FROM ixp_tables where ixp_tables_name = 'ixp_source_price_curve_def_template')
BEGIN
		INSERT INTO ixp_tables(ixp_tables_name,ixp_tables_description,import_export_flag)
		VALUES('ixp_source_price_curve_def_template','Price Curve', 'i')
END
ELSE 
	PRINT 'ixp tables already exists'

	
DECLARE  @ixp_table_id INT 
SELECT @ixp_table_id  = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_source_price_curve_def_template'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'holiday_calendar_id')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'holiday_calendar_id','VARCHAR(600)',0
END

