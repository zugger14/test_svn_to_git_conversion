DECLARE @ixp_table_id INT 
SELECT @ixp_table_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_power_outage'
--select * from ixp_tables where ixp_tables_name = 'ixp_power_outage'
--select * from ixp_columns where ixp_table_id = 94

IF NOT EXISTS (SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_columns_name = 'planned_interval_start' AND ixp_table_id =  @ixp_table_id )
BEGIN 
	INSERT INTO ixp_columns (
		ixp_table_id,
		ixp_columns_name,
		column_datatype,
		is_major,
		header_detail
	) VALUES (
		 @ixp_table_id,
		'planned_interval_start',
		'VARCHAR(600)',
		0,
		NULL
	)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_columns_name = 'planned_interval_end' AND ixp_table_id =  @ixp_table_id )
BEGIN 
	INSERT INTO ixp_columns (
		ixp_table_id,
		ixp_columns_name,
		column_datatype,
		is_major,
		header_detail
	) VALUES (
		 @ixp_table_id,
		'planned_interval_end',
		'VARCHAR(600)',
		0,
		NULL
	)
END
IF NOT EXISTS (SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_columns_name = 'actual_interval_start' AND ixp_table_id =  @ixp_table_id )
BEGIN 
	INSERT INTO ixp_columns (
		ixp_table_id,
		ixp_columns_name,
		column_datatype,
		is_major,
		header_detail
	) VALUES (
		 @ixp_table_id,
		'actual_interval_start',
		'VARCHAR(600)',
		0,
		NULL
	)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_columns_name = 'actual_interval_end' AND ixp_table_id =  @ixp_table_id )
	BEGIN 
	INSERT INTO ixp_columns (
		ixp_table_id,
		ixp_columns_name,
		column_datatype,
		is_major,
		header_detail
	) VALUES (
		 @ixp_table_id,
		'actual_interval_end',
		'VARCHAR(600)',
		0,
		NULL
	)
END