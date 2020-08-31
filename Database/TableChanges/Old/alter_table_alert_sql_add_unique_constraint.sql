IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'UNIQUE'
                    AND   tc.Table_Name = 'alert_sql'
                    AND ccu.COLUMN_NAME = 'alert_sql_name'
)
BEGIN
 ALTER TABLE [dbo].alert_sql WITH NOCHECK ADD CONSTRAINT uc_alert_sql UNIQUE(alert_sql_name)
 PRINT 'Unique Constraints added on alert_sql_name.' 
END
ELSE
BEGIN
 PRINT 'Unique Constraints on alert_sql_name already exists.'
END