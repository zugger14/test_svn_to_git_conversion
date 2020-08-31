IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND   tc.Table_Name = 'user_defined_fields_template'           --table name
                    AND ccu.COLUMN_NAME = 'field_name'          --column name where FK constaint is to be created
)
ALTER TABLE [dbo].user_defined_fields_template WITH NOCHECK ADD CONSTRAINT [FK_user_defined_fields_template_field_name] FOREIGN KEY(field_name)
REFERENCES [dbo].static_data_value ([value_id])

GO

IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND   tc.Table_Name = 'user_defined_fields_template'           --table name
                    AND ccu.COLUMN_NAME = 'field_id'          --column name where FK constaint is to be created
)
ALTER TABLE [dbo].user_defined_fields_template WITH NOCHECK ADD CONSTRAINT [FK_user_defined_fields_template_field_id] FOREIGN KEY(field_name)
REFERENCES [dbo].static_data_value ([value_id])

GO
