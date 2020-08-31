IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND   tc.Table_Name = 'source_minor_location'           
                    AND ccu.COLUMN_NAME = 'proxy_profile_id'          
)
ALTER TABLE [dbo].[source_minor_location] WITH NOCHECK ADD CONSTRAINT [FK_source_minor_location_forecast_profile2] FOREIGN KEY([proxy_profile_id])
REFERENCES [dbo].[forecast_profile] ([profile_id])