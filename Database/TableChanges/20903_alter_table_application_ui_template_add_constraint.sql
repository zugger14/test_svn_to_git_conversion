IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND tc.Table_Name = 'application_ui_template'
                    AND ccu.COLUMN_NAME = 'template_type'
)
ALTER TABLE application_ui_template WITH NOCHECK 
ADD CONSTRAINT [FK_static_data_value_type_id] FOREIGN KEY(template_type)
REFERENCES static_data_value ([value_id])