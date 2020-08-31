DECLARE @df_constaints NVARCHAR(MAX)

SELECT @df_constaints = con.name 
FROM sys.default_constraints con
INNER JOIN  sys.objects t ON con.parent_object_id = t.object_id 
	AND t.name = 'ixp_columns'
INNER JOIN sys.all_columns col ON con.parent_column_id = col.column_id 
	AND col.name = 'column_datatype'
    AND con.parent_object_id = col.object_id

IF @df_constaints IS NOT NULL
BEGIN
	EXEC('ALTER TABLE [dbo].[ixp_columns]  DROP CONSTRAINT ' + @df_constaints )
END

ALTER TABLE dbo.ixp_columns
ADD CONSTRAINT DF_ixp_columns_column_datatype DEFAULT 'NVARCHAR(600)' FOR column_datatype

--Change varchar to nvarchar column data type.
UPDATE ixp_columns SET column_datatype = REPLACE(column_datatype,'VARCHAR','NVARCHAR') WHERE column_datatype LIKE 'VARCHAR%'

UPDATE ixp_columns SET column_datatype = REPLACE(column_datatype,'CHAR','NCHAR') WHERE column_datatype LIKE 'CHAR%'


 
