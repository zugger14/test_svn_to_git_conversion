IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'UNIQUE'
                    AND   tc.Table_Name = 'source_system_book_map'
                    AND ccu.COLUMN_NAME = 'logical_name'
)
BEGIN
	ALTER TABLE [dbo].[source_system_book_map] WITH NOCHECK ADD CONSTRAINT [UC_logical_name] UNIQUE(logical_name)
	PRINT 'Unique Constraints added on logical_name.'	
END
ELSE
BEGIN
	PRINT 'Unique Constraints on logical_name already exists.'
END	
