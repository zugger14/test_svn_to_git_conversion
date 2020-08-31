 
DECLARE @sql VARCHAR(MAX)
IF EXISTS(
			SELECT  1
			FROM sys.foreign_key_columns fkc
			INNER JOIN sys.objects obj
				ON obj.object_id = fkc.constraint_object_id
			INNER JOIN sys.tables tab1
				ON tab1.object_id = fkc.parent_object_id
			INNER JOIN sys.schemas sch
				ON tab1.schema_id = sch.schema_id
			INNER JOIN sys.columns col1
				ON col1.column_id = parent_column_id AND col1.object_id = tab1.object_id
			INNER JOIN sys.tables tab2
				ON tab2.object_id = fkc.referenced_object_id
			INNER JOIN sys.columns col2
				ON col2.column_id = referenced_column_id AND col2.object_id = tab2.object_id
			WHERE tab1.name = 'template_mapping'
				AND col2.name = 'source_commodity_id')
BEGIN 
	SELECT  @sql = 'ALTER TABLE [template_mapping] DROP CONSTRAINT [' + obj.name + ']'
	FROM sys.foreign_key_columns fkc
	INNER JOIN sys.objects obj
		ON obj.object_id = fkc.constraint_object_id
	INNER JOIN sys.tables tab1
		ON tab1.object_id = fkc.parent_object_id
	INNER JOIN sys.schemas sch
		ON tab1.schema_id = sch.schema_id
	INNER JOIN sys.columns col1
		ON col1.column_id = parent_column_id AND col1.object_id = tab1.object_id
	INNER JOIN sys.tables tab2
		ON tab2.object_id = fkc.referenced_object_id
	INNER JOIN sys.columns col2
		ON col2.column_id = referenced_column_id AND col2.object_id = tab2.object_id
	WHERE tab1.name = 'template_mapping'
		AND col2.name = 'source_commodity_id'

	--select @sql
	EXEC(@sql)
END

GO 

IF COL_LENGTH('dbo.template_mapping', 'commodity_id') IS NOT NULL
BEGIN
    ALTER TABLE template_mapping ALTER COLUMN commodity_id INT NULL
END
GO

 