IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'UNIQUE'
                    AND   tc.Table_Name = 'source_system_description'
                    AND ccu.COLUMN_NAME = 'source_system_name'
)
BEGIN
	ALTER TABLE [dbo].[source_system_description] WITH NOCHECK ADD CONSTRAINT [UC_source_system_name] UNIQUE(source_system_name)
	PRINT 'Unique Constraints added on source_system_name.'	
END
ELSE
BEGIN
	PRINT 'Unique Constraints on source_system_name already exists.'
END
