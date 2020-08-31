IF EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND   tc.Table_Name = 'application_ui_filter'
                    AND ccu.COLUMN_NAME = 'report_id'
)
BEGIN
	DECLARE @constraint_name VARCHAR(100)
	SELECT @constraint_name = tc.CONSTRAINT_NAME
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND   tc.Table_Name = 'application_ui_filter'
                    AND ccu.COLUMN_NAME = 'report_id'
	EXEC('ALTER TABLE [dbo].[application_ui_filter] DROP CONSTRAINT [' + @constraint_name + ']') 
END
GO