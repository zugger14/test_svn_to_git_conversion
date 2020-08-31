IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
                    AND   tc.Table_Name = 'alert_reports' 
                    AND ccu.COLUMN_NAME = 'alert_reports_id'
)
ALTER TABLE [dbo].[alert_reports] WITH NOCHECK ADD CONSTRAINT [PK_alert_reports] PRIMARY KEY([alert_reports_id])
GO