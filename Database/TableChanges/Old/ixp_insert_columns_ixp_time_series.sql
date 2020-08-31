
IF NOT EXISTS(SELECT 1 FROM ixp_columns c INNER JOIN ixp_tables t ON t.ixp_tables_id = c.ixp_table_id AND t.ixp_tables_name = 'ixp_time_series'
WHERE ixp_columns_name = 'time_series_id')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT  ixp_tables_id,'time_series_id','VARCHAR(600)',0 FROM ixp_tables WHERE ixp_tables_name = 'ixp_time_series'
END
ELSE 
	PRINT 'time_series_id is already present in the db'


IF NOT EXISTS(SELECT 1 FROM ixp_columns c INNER JOIN ixp_tables t ON t.ixp_tables_id = c.ixp_table_id AND t.ixp_tables_name = 'ixp_time_series'
WHERE ixp_columns_name = 'effective_date')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT  ixp_tables_id,'effective_date','VARCHAR(600)',0 FROM ixp_tables WHERE ixp_tables_name = 'ixp_time_series'
END
ELSE 
	PRINT 'effective_date is already present in the db'


IF NOT EXISTS(SELECT 1 FROM ixp_columns c INNER JOIN ixp_tables t ON t.ixp_tables_id = c.ixp_table_id AND t.ixp_tables_name = 'ixp_time_series'
WHERE ixp_columns_name = 'maturity')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT  ixp_tables_id,'maturity','VARCHAR(600)',0 FROM ixp_tables WHERE ixp_tables_name = 'ixp_time_series'
END
ELSE 
	PRINT 'maturity is already present in the db'


IF NOT EXISTS(SELECT 1 FROM ixp_columns c INNER JOIN ixp_tables t ON t.ixp_tables_id = c.ixp_table_id AND t.ixp_tables_name = 'ixp_time_series'
WHERE ixp_columns_name = 'curve_source_value_id')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT  ixp_tables_id,'curve_source_value_id','VARCHAR(600)',0 FROM ixp_tables WHERE ixp_tables_name = 'ixp_time_series'
END
ELSE 
	PRINT 'curve_source_value_id is already present in the db'


IF NOT EXISTS(SELECT 1 FROM ixp_columns c INNER JOIN ixp_tables t ON t.ixp_tables_id = c.ixp_table_id AND t.ixp_tables_name = 'ixp_time_series'
WHERE ixp_columns_name = 'value')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT  ixp_tables_id,'value','VARCHAR(600)',0 FROM ixp_tables WHERE ixp_tables_name = 'ixp_time_series'
END
ELSE 
	PRINT 'value is already present in the db'


IF NOT EXISTS(SELECT 1 FROM ixp_columns c INNER JOIN ixp_tables t ON t.ixp_tables_id = c.ixp_table_id AND t.ixp_tables_name = 'ixp_time_series'
WHERE ixp_columns_name = 'is_dst')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT  ixp_tables_id,'is_dst','VARCHAR(600)',0 FROM ixp_tables WHERE ixp_tables_name = 'ixp_time_series'
END
ELSE 
	PRINT 'is_dst is already present in the db'

IF NOT EXISTS(SELECT 1 FROM ixp_columns c INNER JOIN ixp_tables t ON t.ixp_tables_id = c.ixp_table_id AND t.ixp_tables_name = 'ixp_time_series'
WHERE ixp_columns_name = 'create_user')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT  ixp_tables_id,'create_user','VARCHAR(600)',0 FROM ixp_tables WHERE ixp_tables_name = 'ixp_time_series'
END
ELSE 
	PRINT 'create_user is already present in the db'

IF NOT EXISTS(SELECT 1 FROM ixp_columns c INNER JOIN ixp_tables t ON t.ixp_tables_id = c.ixp_table_id AND t.ixp_tables_name = 'ixp_time_series'
WHERE ixp_columns_name = 'create_ts')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT  ixp_tables_id,'create_ts','VARCHAR(600)',0 FROM ixp_tables WHERE ixp_tables_name = 'ixp_time_series'
END
ELSE 
	PRINT 'create_ts is already present in the db'

IF NOT EXISTS(SELECT 1 FROM ixp_columns c INNER JOIN ixp_tables t ON t.ixp_tables_id = c.ixp_table_id AND t.ixp_tables_name = 'ixp_time_series'
WHERE ixp_columns_name = 'update_user')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT  ixp_tables_id,'update_user','VARCHAR(600)',0 FROM ixp_tables WHERE ixp_tables_name = 'ixp_time_series'
END
ELSE 
	PRINT 'update_user is already present in the db'

IF NOT EXISTS(SELECT 1 FROM ixp_columns c INNER JOIN ixp_tables t ON t.ixp_tables_id = c.ixp_table_id AND t.ixp_tables_name = 'ixp_time_series'
WHERE ixp_columns_name = 'update_ts')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT  ixp_tables_id,'update_ts','VARCHAR(600)',0 FROM ixp_tables WHERE ixp_tables_name = 'ixp_time_series'
END
ELSE 
	PRINT 'update_ts is already present in the db'

IF NOT EXISTS(SELECT 1 FROM ixp_columns c INNER JOIN ixp_tables t ON t.ixp_tables_id = c.ixp_table_id AND t.ixp_tables_name = 'ixp_time_series'
WHERE ixp_columns_name = 'static_data_type')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT  ixp_tables_id,'static_data_type','VARCHAR(600)',0 FROM ixp_tables WHERE ixp_tables_name = 'ixp_time_series'
END
ELSE 
	PRINT 'static_data_type is already present in the db'

IF NOT EXISTS(SELECT 1 FROM ixp_columns c INNER JOIN ixp_tables t ON t.ixp_tables_id = c.ixp_table_id AND t.ixp_tables_name = 'ixp_time_series'
WHERE ixp_columns_name = 'static_data_value')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT  ixp_tables_id,'static_data_value','VARCHAR(600)',0 FROM ixp_tables WHERE ixp_tables_name = 'ixp_time_series'
END
ELSE 
	PRINT 'static_data_value is already present in the db'


IF NOT EXISTS(SELECT 1 FROM ixp_columns c INNER JOIN ixp_tables t ON t.ixp_tables_id = c.ixp_table_id AND t.ixp_tables_name = 'ixp_time_series'
WHERE ixp_columns_name = 'series_source')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT  ixp_tables_id,'series_source','VARCHAR(600)',0 FROM ixp_tables WHERE ixp_tables_name = 'ixp_time_series'
END
ELSE 
	PRINT 'series_source is already present in the db'

IF NOT EXISTS(SELECT 1 FROM ixp_columns c INNER JOIN ixp_tables t ON t.ixp_tables_id = c.ixp_table_id AND t.ixp_tables_name = 'ixp_time_series'
WHERE ixp_columns_name = 'hour')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT  ixp_tables_id,'hour','VARCHAR(600)',0 FROM ixp_tables WHERE ixp_tables_name = 'ixp_time_series'
END
ELSE 
	PRINT 'hour is already present in the db'
