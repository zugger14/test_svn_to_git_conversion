IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND   tc.Table_Name = 'source_deal_header_template'           --table name
                    AND ccu.COLUMN_NAME = 'field_template_id'          --column name where FK constaint is to be created
)
ALTER TABLE [dbo].source_deal_header_template WITH NOCHECK ADD CONSTRAINT [FK_source_deal_header_template_field_template_id] FOREIGN KEY(field_template_id)
REFERENCES [dbo]. maintain_field_template (field_template_id)

GO

