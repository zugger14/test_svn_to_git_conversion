
IF EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'UNIQUE'
                    AND   tc.Table_Name = 'user_defined_fields_template'     
                    AND ccu.COLUMN_NAME = 'Field_label'       
)
BEGIN
	ALTER TABLE dbo.user_defined_fields_template DROP CONSTRAINT [UC_user_defined_fields_template_field_lable]
END

GO

IF COL_LENGTH(N'user_defined_fields_template', N'Field_label') IS  NOT NULL
BEGIN 
	ALTER TABLE [user_defined_fields_template] ALTER COLUMN [Field_label] NVARCHAR(50) 
END

GO

IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'UNIQUE'
                    AND   tc.Table_Name = 'user_defined_fields_template'     
                    AND ccu.COLUMN_NAME = 'Field_label'       
)
BEGIN
	ALTER TABLE [dbo].[user_defined_fields_template] WITH NOCHECK ADD CONSTRAINT [UC_user_defined_fields_template_field_lable] UNIQUE(Field_label,udf_type)
END

