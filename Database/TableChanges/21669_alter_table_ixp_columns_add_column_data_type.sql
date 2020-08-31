IF NOT EXISTS( SELECT 1 FROM sys.tables t INNER JOIN sys.columns c on t.object_id = c.object_id where t.name = 'ixp_columns' and c.name = 'datatype')
BEGIN
	ALTER TABLE ixp_columns
	ADD  datatype VARCHAR(200)
END
ELSE 
	PRINT 'Column datatype already exists in ixp_columns table'
