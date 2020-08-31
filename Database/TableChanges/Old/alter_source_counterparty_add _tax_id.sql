IF NOT EXISTS(SELECT 1
                FROM INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_SCHEMA = 'dbo'
                      AND TABLE_NAME = 'source_counterparty'     
                      AND COLUMN_NAME = 'tax_id'    
                      AND COLUMN_DEFAULT IS NOT NULL)
BEGIN
    ALTER TABLE dbo.source_counterparty
    ADD tax_id  VARCHAR(500)
END

GO