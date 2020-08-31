DECLARE @constraint_name VARCHAR(500)
SELECT @constraint_name = d.name
FROM sys.all_columns c
INNER JOIN sys.tables t ON t.object_id = c.object_id
INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
INNER JOIN sys.default_constraints d ON c.default_object_id = d.object_id
WHERE t.name = 'ixp_import_data_interface_staging'
	AND c.name = 'create_user'

IF @constraint_name IS NOT NULL
BEGIN	
	EXEC('ALTER TABLE ixp_import_data_interface_staging DROP CONSTRAINT ' + @constraint_name)
END 
ELSE
BEGIN
	ALTER TABLE ixp_import_data_interface_staging 
	ADD CONSTRAINT DF_create_user DEFAULT dbo.FNAdbuser ()
	FOR create_user;
END


