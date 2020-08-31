IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'UNIQUE'
                    AND   tc.Table_Name = 'region'
                    AND ccu.COLUMN_NAME = 'region_name'
)
BEGIN
 ALTER TABLE [dbo].region WITH NOCHECK ADD CONSTRAINT [UC_region_name] UNIQUE(region_name)
 PRINT 'Unique Constraints added on region_name.' 
END
ELSE
BEGIN
 PRINT 'Unique Constraints on region_name already exists.'
END
