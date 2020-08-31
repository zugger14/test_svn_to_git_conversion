/**
	Unique Constraint for report_paramset 
	Name : UC_report_paramset_name
	Table : report_paramset
	Column : name
*/
IF EXISTS( 
	SELECT 1
	FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
	INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
		AND tc.Constraint_name = ccu.Constraint_name    
        AND tc.CONSTRAINT_TYPE = 'UNIQUE'
        AND tc.Table_Name = 'report_paramset'
		AND	tc.CONSTRAINT_NAME = 'UC_report_paramset_name'
)
BEGIN
	ALTER TABLE 
	/**
		Columns
		name : Name of report paramset
	*/
	[dbo].report_paramset
	DROP CONSTRAINT [UC_report_paramset_name]
	PRINT 'Unique constraint deleted'
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
        AND tc.CONSTRAINT_TYPE = 'UNIQUE'
        AND tc.Table_Name = 'report_paramset'
		AND	tc.CONSTRAINT_NAME = 'UC_report_paramset_name'
)
BEGIN
	ALTER TABLE 
	/**
		Columns
		name : Name of report paramset
	*/
	[dbo].report_paramset WITH NOCHECK 
	ADD CONSTRAINT UC_report_paramset_name UNIQUE (
		[name]
	)
	PRINT 'Unique constraint added'
END
ELSE
BEGIN
	PRINT 'Already Added'
END

GO