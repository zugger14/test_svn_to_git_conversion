IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'UNIQUE'
                    AND   tc.Table_Name = 'user_defined_fields_template'      
                    AND ccu.COLUMN_NAME = 'field_name'      
)
ALTER TABLE [dbo].user_defined_fields_template WITH NOCHECK ADD CONSTRAINT 
[UC_user_defined_fields_template_field_name] UNIQUE(field_name)

GO

IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                    AND tc.Table_Name = 'user_defined_fields_template'      
                    AND ccu.COLUMN_NAME = 'field_id'      
)
ALTER TABLE [dbo].user_defined_fields_template WITH NOCHECK ADD CONSTRAINT 
[UC_user_defined_fields_template_field_id] UNIQUE(field_id)

GO

IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                    AND tc.Table_Name = 'user_defined_fields_template'      
                    AND ccu.COLUMN_NAME = 'field_label'      
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu1
                   ON  tc.TABLE_NAME = ccu1.TABLE_NAME
                   AND tc.Constraint_name = ccu1.Constraint_name
                   AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                   AND tc.Table_Name = 'user_defined_fields_template'
                   AND ccu1.COLUMN_NAME = 'udf_type'

)
ALTER TABLE [dbo].user_defined_fields_template WITH NOCHECK ADD CONSTRAINT 
[UC_user_defined_fields_template_field_lable] UNIQUE(field_label, udf_type)


GO
