
IF NOT EXISTS(SELECT 1 FROM sys.tables  t INNER JOIN sys.columns c ON c.object_id = t.object_id where t.name = 'source_minor_location' AND c.name = 'station_id')
BEGIN
	alter table source_minor_location add station_id int
	alter table source_minor_location add dam_id int
END
ELSE 
	PRINT 'Column already added'

