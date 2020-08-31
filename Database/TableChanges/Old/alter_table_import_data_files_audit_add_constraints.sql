
IF NOT EXISTS(SELECT 1
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'dbo'
     AND TABLE_NAME = 'import_data_files_audit'
     AND COLUMN_NAME = 'create_ts'
     AND COLUMN_DEFAULT IS NOT NULL)  
BEGIN
 ALTER TABLE dbo.import_data_files_audit ADD
   CONSTRAINT DF_import_data_files_audit_create_ts DEFAULT GETDATE() FOR create_ts,
   CONSTRAINT DF_import_data_files_audit_create_user DEFAULT dbo.FNADBUserDefault() FOR create_user
END
GO