IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'UNIQUE'
                    AND   tc.Table_Name = 'alert_table_relation'
                    AND ccu.COLUMN_NAME IN ('alert_id', 'from_table_id', 'from_column_id', 'to_table_id', 'to_column_id')
)
BEGIN
 ALTER TABLE [dbo].alert_table_relation WITH NOCHECK ADD CONSTRAINT uc_alert_table_relation UNIQUE(alert_id, from_table_id, from_column_id, to_table_id, to_column_id)
 PRINT 'Unique Constraints added on alert_id, from_table_id, from_column_id, to_table_id, to_column_id.' 
END
ELSE
BEGIN
 PRINT 'Unique Constraints on alert_id, from_table_id, from_column_id, to_table_id, to_column_id already exists.'
END

