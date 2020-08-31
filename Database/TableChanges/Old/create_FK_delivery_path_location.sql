IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND   tc.Table_Name = 'delivery_path'           --table name
                    AND ccu.COLUMN_NAME = 'location_id'          --column name where FK constaint is to be created
)
ALTER TABLE [dbo].delivery_path WITH NOCHECK ADD CONSTRAINT [FK_delivery_path_location_id] FOREIGN KEY(location_id)
REFERENCES [dbo]. source_minor_location (source_minor_location_id)

GO

IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND   tc.Table_Name = 'delivery_path'           --table name
                    AND ccu.COLUMN_NAME = 'from_location'          --column name where FK constaint is to be created
)
ALTER TABLE [dbo].delivery_path WITH NOCHECK ADD CONSTRAINT [FK_delivery_path_from_location] FOREIGN KEY(from_location)
REFERENCES [dbo]. source_minor_location (source_minor_location_id)

GO

IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND   tc.Table_Name = 'delivery_path'           --table name
                    AND ccu.COLUMN_NAME = 'to_location'          --column name where FK constaint is to be created
)
ALTER TABLE [dbo].delivery_path WITH NOCHECK ADD CONSTRAINT [FK_delivery_path_to_location] FOREIGN KEY(to_location)
REFERENCES [dbo]. source_minor_location (source_minor_location_id)

GO


IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND   tc.Table_Name = 'maintain_location_routes'           --table name
                    AND ccu.COLUMN_NAME = 'delivery_location'          --column name where FK constaint is to be created
)
ALTER TABLE [dbo].maintain_location_routes WITH NOCHECK ADD CONSTRAINT [FK_maintain_location_routes_delivery_location] FOREIGN KEY(delivery_location)
REFERENCES [dbo]. source_minor_location (source_minor_location_id)

GO

