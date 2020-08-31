IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'UNIQUE'
                    AND   tc.Table_Name = 'alert_table_definition'
                    AND ccu.COLUMN_NAME = 'logical_table_name'
)
BEGIN
 ALTER TABLE [dbo].alert_table_definition WITH NOCHECK ADD CONSTRAINT uc_alert_table_definition UNIQUE(logical_table_name)
 PRINT 'Unique Constraints added on logical_table_name.' 
END
ELSE
BEGIN
 PRINT 'Unique Constraints on logical_table_name already exists.'
END 