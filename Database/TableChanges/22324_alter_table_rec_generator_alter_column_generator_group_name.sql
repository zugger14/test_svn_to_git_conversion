IF NOT EXISTS(SELECT 1 FROM sys.tables t INNER JOIN sys.columns c ON c.object_id = t.object_id 
	WHERE t.name = 'rec_generator' AND c.name = 'generator_group_name')
BEGIN
	ALTER TABLE rec_generator ALTER COLUMN generator_group_name INT

	PRINT 'Altered column generator_group_name.'
END

