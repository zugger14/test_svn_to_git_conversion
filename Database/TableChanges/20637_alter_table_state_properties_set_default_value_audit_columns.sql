IF NOT EXISTS(SELECT 1
                FROM INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_SCHEMA = 'dbo'
                      AND TABLE_NAME = 'state_properties'      --table name
                      AND COLUMN_NAME = 'create_ts'    --column name where DEFAULT constaint it to be created
                      AND COLUMN_DEFAULT IS NOT NULL)
BEGIN
    ALTER TABLE dbo.state_properties
    ADD CONSTRAINT DF_state_properties_create_ts DEFAULT GETDATE() FOR create_ts
    , CONSTRAINT DF_state_properties_create_user DEFAULT dbo.FNADBUser() FOR create_user
END
GO
