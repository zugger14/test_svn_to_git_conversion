DECLARE @ixp_hourly_allocation_data_template_id INT	
SELECT @ixp_hourly_allocation_data_template_id = it.ixp_tables_id FROM   ixp_tables it WHERE  it.ixp_tables_name = 'ixp_hourly_allocation_data_template'

IF @ixp_hourly_allocation_data_template_id IS NOT NULL
BEGIN
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'end_date' AND ixp_table_id = @ixp_hourly_allocation_data_template_id) 
	BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) 
	SELECT @ixp_hourly_allocation_data_template_id, 'end_date', 0, NULL END
	END
ELSE
BEGIN
	SELECT 'ixp_hourly_allocation_data_template not present in ixp_tables'
END