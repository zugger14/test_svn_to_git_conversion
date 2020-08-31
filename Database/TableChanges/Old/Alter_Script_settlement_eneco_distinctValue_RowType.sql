IF NOT EXISTS(SELECT 1 FROM sys.tables t INNER JOIN sys.columns c ON t.object_id = c.object_id WHERE t.name = 'Settlement_export' AND c.name = 'Distinct_value')
BEGIN
	Alter TABLE Settlement_export
	ADD Distinct_value INT
END 
ELSE 
PRINT 'Column Already Present'

IF NOT EXISTS(SELECT 1 FROM sys.tables t INNER JOIN sys.columns c ON t.object_id = c.object_id WHERE t.name = 'Settlement_export' AND c.name = 'row_type')
BEGIN
	ALTER  TABLE settlement_export
	ADD row_type CHAR(2)
END 
ELSE 
PRINT 'Column Already Present'
