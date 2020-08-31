/**
* drop column portfolio_group_id from table limit_header
**/

IF EXISTS(
	SELECT name
	FROM   sys.foreign_keys
	WHERE  parent_object_id = OBJECT_ID(N'dbo.limit_header')
		  AND referenced_object_id = OBJECT_ID(N'maintain_portfolio_group')
)
BEGIN
	DECLARE @fk_name VARCHAR(500), @sql VARCHAR(1000)
	SELECT @fk_name = name
	FROM   sys.foreign_keys
	WHERE  parent_object_id = OBJECT_ID(N'dbo.limit_header')
			AND referenced_object_id = OBJECT_ID(N'maintain_portfolio_group')
	SET @sql = '
	ALTER TABLE dbo.limit_header
	DROP CONSTRAINT ' + @fk_name
	PRINT(@sql)
	EXEC(@sql)
END

IF COL_LENGTH(N'dbo.limit_header', N'portfolio_group_id') IS NOT NULL
BEGIN
	ALTER TABLE dbo.limit_header
	DROP COLUMN portfolio_group_id
END
ELSE
	PRINT 'Column portfolio_group_id does not exist.'