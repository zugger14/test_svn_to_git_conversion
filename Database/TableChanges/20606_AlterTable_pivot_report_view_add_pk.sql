IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
                    AND   tc.Table_Name = 'pivot_report_view' 
                    AND ccu.COLUMN_NAME = 'pivot_report_view_id'
)
ALTER TABLE [dbo].pivot_report_view WITH NOCHECK ADD CONSTRAINT pk_pivot_report_view_id PRIMARY KEY(pivot_report_view_id)
GO
