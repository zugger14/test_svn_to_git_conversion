IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'UNIQUE'
                    AND   tc.Table_Name = 'alert_reports'
                    AND ccu.COLUMN_NAME IN ('alert_sql_id', 'report_desc', 'table_prefix', 'table_postfix', 'report_param')
)
BEGIN
 ALTER TABLE [dbo].alert_reports WITH NOCHECK ADD CONSTRAINT uc_alert_reports UNIQUE(alert_sql_id, report_desc, table_prefix, table_postfix, report_param)
 PRINT 'Unique Constraints added on alert_sql_id, report_desc, table_prefix, table_postfix, report_param.' 
END
ELSE
BEGIN
	ALTER TABLE alert_reports DROP CONSTRAINT uc_alert_reports 
	ALTER TABLE [dbo].alert_reports WITH NOCHECK ADD CONSTRAINT uc_alert_reports UNIQUE(alert_sql_id, report_desc, table_prefix, table_postfix, report_param)
	PRINT 'Unique Constraints added on alert_sql_id, report_desc, table_prefix, table_postfix, report_param.'
END

