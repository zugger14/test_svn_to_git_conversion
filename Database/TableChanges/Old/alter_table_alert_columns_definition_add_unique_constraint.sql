IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'UNIQUE'
                    AND   tc.Table_Name = 'alert_columns_definition'
                    AND ccu.COLUMN_NAME IN ('alert_table_id', 'column_name')
)
BEGIN
 ALTER TABLE [dbo].alert_columns_definition WITH NOCHECK ADD CONSTRAINT uc_alert_columns_definition UNIQUE(alert_table_id, column_name)
 PRINT 'Unique Constraints added on alert_table_id, column_name.' 
END
ELSE
BEGIN
 PRINT 'Unique Constraints on alert_table_id, column_name already exists.'
END