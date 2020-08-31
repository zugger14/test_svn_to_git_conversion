IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'UNIQUE'
                    AND   tc.Table_Name = 'contract_report_template'
                    AND ccu.COLUMN_NAME = 'template_name'
)
BEGIN
	ALTER TABLE [dbo].[contract_report_template] WITH NOCHECK ADD CONSTRAINT [UC_template_name] UNIQUE(template_name)
	PRINT 'Unique Constraints added on template_name.'	
END
ELSE
BEGIN
	PRINT 'Unique Constraints on template_name already exists.'
END