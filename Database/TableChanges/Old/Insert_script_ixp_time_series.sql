IF NOT EXISTS(Select 1 FROM ixp_tables where ixp_tables_name = 'ixp_time_series')
BEGIN
	 INSERT INTO ixp_tables(ixp_tables_name,ixp_tables_description,import_export_flag)
		Select 'ixp_time_series','Time series','i'
END
ELSE 
	PRINT 'Time Series Table already exists.'
