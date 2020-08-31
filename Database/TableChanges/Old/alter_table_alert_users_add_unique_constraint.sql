IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'UNIQUE'
                    AND   tc.Table_Name = 'alert_users'
                    AND ccu.COLUMN_NAME IN ('alert_sql_id', 'role_user', 'role_id', 'user_login_id')
)
BEGIN
 ALTER TABLE [dbo].alert_users WITH NOCHECK ADD CONSTRAINT uc_alert_users UNIQUE(alert_sql_id, role_user, role_id, user_login_id)
 PRINT 'Unique Constraints added on alert_sql_id, role_user, role_id, user_login_id.' 
END
ELSE
BEGIN
 PRINT 'Unique Constraints on alert_sql_id, role_user, role_id, user_login_id already exists.'
END