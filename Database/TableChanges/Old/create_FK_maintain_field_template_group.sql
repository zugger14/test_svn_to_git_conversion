IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND   tc.Table_Name = 'maintain_field_template_group'           --table name
                    AND ccu.COLUMN_NAME = 'field_template_id'          --column name where FK constaint is to be created
)
ALTER TABLE [dbo].maintain_field_template_group WITH NOCHECK ADD CONSTRAINT [FK_maintain_field_template_group_field_template_id] FOREIGN KEY(field_template_id)
REFERENCES [dbo]. maintain_field_template (field_template_id)

GO