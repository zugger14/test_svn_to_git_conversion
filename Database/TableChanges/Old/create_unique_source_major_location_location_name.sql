IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'UNIQUE'
                    AND   tc.Table_Name = 'source_major_location'      --table name
                    AND ccu.COLUMN_NAME = 'location_name'       --column name where UNIQUE constaint/index is to be created
)
ALTER TABLE [dbo].[source_major_location] ADD CONSTRAINT [unique_source_major_location_location_name] UNIQUE(location_name)