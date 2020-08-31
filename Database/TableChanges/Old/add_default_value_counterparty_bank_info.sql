--ALTER TABLE dbo.[counterparty_bank_info] ADD  DEFAULT (dbo.FNADBUser()) FOR create_user
--ALTER TABLE dbo.[counterparty_bank_info] ADD  DEFAULT (GETDATE()) FOR create_ts


IF NOT EXISTS(SELECT 1
                FROM INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_SCHEMA = 'dbo'
                      AND TABLE_NAME = 'counterparty_bank_info'     
                      AND COLUMN_NAME = 'create_user'    
                      AND COLUMN_DEFAULT IS NOT NULL)
BEGIN
    ALTER TABLE dbo.counterparty_bank_info
    ADD CONSTRAINT DF_counterparty_bank_info_create_user DEFAULT dbo.FNADBUser() FOR create_user
END

IF NOT EXISTS(SELECT 1
                FROM INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_SCHEMA = 'dbo'
                      AND TABLE_NAME = 'counterparty_bank_info'     
                      AND COLUMN_NAME = 'create_ts'    
                      AND COLUMN_DEFAULT IS NOT NULL)
BEGIN
    ALTER TABLE dbo.counterparty_bank_info
    ADD CONSTRAINT DF_counterparty_bank_info_create_ts DEFAULT GETDATE() FOR create_ts    
END
GO