IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'UNIQUE'
                    AND   tc.Table_Name = 'alert_actions_events'
                    AND ccu.COLUMN_NAME IN ('alert_id', 'table_id', 'callback_alert_id')
)
BEGIN
 ALTER TABLE [dbo].alert_actions_events WITH NOCHECK ADD CONSTRAINT uc_alert_actions_events UNIQUE(alert_id, table_id, callback_alert_id)
 PRINT 'Unique Constraints added on alert_id, table_id, callback_alert_id.' 
END
ELSE
BEGIN
 PRINT 'Unique Constraints on alert_id, table_id, callback_alert_id already exists.'
END