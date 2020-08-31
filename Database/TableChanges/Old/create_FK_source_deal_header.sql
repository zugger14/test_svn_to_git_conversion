IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND   tc.Table_Name = 'source_deal_header'           --table name
                    AND ccu.COLUMN_NAME = 'template_id'          --column name where FK constaint is to be created
)
ALTER TABLE [dbo].source_deal_header WITH NOCHECK ADD CONSTRAINT [FK_source_deal_header_template_id] FOREIGN KEY(template_id)
REFERENCES [dbo]. source_deal_header_template (template_id)

GO