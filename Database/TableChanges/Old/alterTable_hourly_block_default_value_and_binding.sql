IF NOT EXISTS(SELECT 1
                FROM INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_SCHEMA = 'dbo'
                      AND TABLE_NAME = 'hourly_block'     
                      AND COLUMN_NAME = 'create_ts'    
                      AND COLUMN_DEFAULT IS NOT NULL)
BEGIN
    ALTER TABLE dbo.hourly_block
    ADD CONSTRAINT DF_hb_value_create_ts DEFAULT GETDATE() FOR create_ts    
END
GO

IF NOT EXISTS(SELECT 1
                FROM INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_SCHEMA = 'dbo'
                      AND TABLE_NAME = 'hourly_block'     
                      AND COLUMN_NAME = 'create_user'    
                      AND COLUMN_DEFAULT IS NOT NULL)
BEGIN
    ALTER TABLE dbo.hourly_block
    ADD CONSTRAINT DF_hb_value_create_user DEFAULT dbo.FNADBUser() FOR create_user
END
GO