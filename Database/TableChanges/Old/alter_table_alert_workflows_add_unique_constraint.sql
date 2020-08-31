IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'UNIQUE'
                    AND   tc.Table_Name = 'alert_workflows'
                    AND ccu.COLUMN_NAME IN ('alert_sql_id', 'workflow_id')
)
BEGIN
 ALTER TABLE [dbo].alert_workflows WITH NOCHECK ADD CONSTRAINT uc_alert_workflows UNIQUE(alert_sql_id, workflow_id)
 PRINT 'Unique Constraints added on rules_id, alert_conditions_name.' 
END
ELSE
BEGIN
 PRINT 'Unique Constraints on alert_sql_id, workflow_id already exists.'
END 