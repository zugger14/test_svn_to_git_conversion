IF NOT EXISTS(SELECT 1
                FROM INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_SCHEMA = 'dbo'
                      AND TABLE_NAME = 'source_deal_detail'      --table name
                      AND COLUMN_NAME = 'pay_opposite'    --column name where DEFAULT constaint it to be created
                      AND COLUMN_DEFAULT IS NOT NULL)
BEGIN
    ALTER TABLE dbo.source_deal_detail
    ADD CONSTRAINT DF_pay_opposite DEFAULT 'y' FOR pay_opposite
    PRINT 'Set ''y'' as default value for pay opposite'
END 	
 