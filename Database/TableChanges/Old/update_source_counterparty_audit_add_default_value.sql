--truncate table source_counterparty_audit

IF NOT EXISTS(SELECT 1
                FROM INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_SCHEMA = 'dbo'
                      AND TABLE_NAME = 'source_counterparty_audit'     
                      AND COLUMN_NAME = 'create_user'    
                      AND COLUMN_DEFAULT IS NOT NULL)
BEGIN
    ALTER TABLE dbo.source_counterparty_audit
    ADD CONSTRAINT DF_source_counterparty_audit_create_user DEFAULT dbo.FNADBUser() FOR create_user
END

IF NOT EXISTS(SELECT 1
                FROM INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_SCHEMA = 'dbo'
                      AND TABLE_NAME = 'source_counterparty_audit'     
                      AND COLUMN_NAME = 'create_ts'    
                      AND COLUMN_DEFAULT IS NOT NULL)
BEGIN
    ALTER TABLE dbo.source_counterparty_audit
    ADD CONSTRAINT DF_source_counterparty_audit_create_ts DEFAULT GETDATE() FOR create_ts    
END
GO