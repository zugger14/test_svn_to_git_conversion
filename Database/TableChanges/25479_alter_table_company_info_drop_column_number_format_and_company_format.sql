DECLARE @sql NVARCHAR(MAX)
/**
	Drop default constraint for column number_format
*/
WHILE 1=1
BEGIN
    SELECT TOP 1 @sql = N'alter table company_info drop constraint ['+dc.NAME+N']'
    FROM sys.default_constraints dc
    JOIN sys.columns c
        ON c.default_object_id = dc.object_id
    WHERE dc.parent_object_id = OBJECT_ID('company_info')
    AND c.name = N'number_format'
    
	IF @@ROWCOUNT = 0 BREAK
	EXEC (@sql)
END

/**
	Drop default constraint for column price_format
*/

WHILE 1=1
BEGIN
    SELECT TOP 1 @sql = N'alter table company_info drop constraint ['+dc.NAME+N']'
    FROM sys.default_constraints dc
    JOIN sys.columns c
        ON c.default_object_id = dc.object_id
    WHERE dc.parent_object_id = OBJECT_ID('company_info')
    AND c.name = N'price_format'
    IF @@ROWCOUNT = 0 BREAK
	EXEC (@sql)
END

IF COL_LENGTH(N'[dbo].[company_info]', N'number_format') IS NOT NULL
BEGIN
    ALTER TABLE
	/**
		Columns
		number_format : Drop column number_format
	*/
	[dbo].[company_info] DROP COLUMN number_format
	PRINT 'number_format column dropped'
END
GO

IF COL_LENGTH(N'[dbo].[company_info]', N'price_format') IS NOT NULL
BEGIN
    ALTER TABLE
	/**
		Columns
		price_format : Drop column price_format
	*/
		[dbo].[company_info] DROP COLUMN price_format
	PRINT 'price_format column dropped'
END
GO