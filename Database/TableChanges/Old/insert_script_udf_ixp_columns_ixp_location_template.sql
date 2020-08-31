

-- ixp_location_template starts
DECLARE @ixp_deal_detail_hour_template_id INT	
SELECT @ixp_deal_detail_hour_template_id = it.ixp_tables_id FROM   ixp_tables it WHERE  it.ixp_tables_name = 'ixp_location_template'

IF @ixp_deal_detail_hour_template_id IS NOT NULL
BEGIN
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'udf1' AND ixp_table_id = @ixp_deal_detail_hour_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_deal_detail_hour_template_id, 'udf1', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'udf2' AND ixp_table_id = @ixp_deal_detail_hour_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_deal_detail_hour_template_id, 'udf2', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'udf3' AND ixp_table_id = @ixp_deal_detail_hour_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_deal_detail_hour_template_id, 'udf3', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'udf4' AND ixp_table_id = @ixp_deal_detail_hour_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_deal_detail_hour_template_id, 'udf4', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'udf5' AND ixp_table_id = @ixp_deal_detail_hour_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_deal_detail_hour_template_id, 'udf5', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'udf6' AND ixp_table_id = @ixp_deal_detail_hour_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_deal_detail_hour_template_id, 'udf6', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'pipeline' AND ixp_table_id = @ixp_deal_detail_hour_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_deal_detail_hour_template_id, 'pipeline', 0, NULL END
END
ELSE
BEGIN
	SELECT 'ixp_location_template not present in ixp_tables'
END

