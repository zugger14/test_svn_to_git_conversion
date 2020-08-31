/**
	Check Constraint for data_source 
	Name : CK_data_source
	Table : data_source
	Column : name, type_id
*/
IF EXISTS( 
	SELECT 1
	FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
	INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
		AND tc.Constraint_name = ccu.Constraint_name    
        AND tc.CONSTRAINT_TYPE = 'CHECK'
        AND tc.Table_Name = 'data_source'
		AND	tc.CONSTRAINT_NAME = 'CK_data_source'
)
BEGIN
	ALTER TABLE 
	/**
		Columns
		name : Name of data_source
	*/
	[dbo].[data_source]
	DROP CONSTRAINT [CK_data_source]
	PRINT 'Check constraint deleted'
END
ELSE
BEGIN
	PRINT 'Already Deleted'
END

IF NOT EXISTS( 
	SELECT 1
	FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
	INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
		AND tc.Constraint_name = ccu.Constraint_name    
        AND tc.CONSTRAINT_TYPE = 'CHECK'
        AND tc.Table_Name = 'data_source'
		AND	tc.CONSTRAINT_NAME = 'CK_data_source'
)
BEGIN
	ALTER TABLE 
	/**
		Columns
		name : Name of data_source
		type_id : 1-> Views, 2-> SQL, 3-> Tables
		data_source_id : Data Source ID
		report_id : Report ID
	*/
	[dbo].[data_source] WITH NOCHECK 
	ADD CONSTRAINT CK_data_source CHECK (dbo.FNACheckUniqueDatasourceName([name],[type_id],[data_source_id],[report_id]) = 1)
	PRINT 'Check constraint added'
END
ELSE
BEGIN
	PRINT 'Already Added'
END

GO