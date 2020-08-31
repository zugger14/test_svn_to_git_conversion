IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND   tc.Table_Name = 'user_defined_deal_fields'           --table name
                    AND ccu.COLUMN_NAME = 'udf_template_id'          --column name where FK constaint is to be created
)
ALTER TABLE [dbo].user_defined_deal_fields WITH NOCHECK ADD CONSTRAINT [FK_user_defined_deal_fields_udf_template_id] FOREIGN KEY(udf_template_id)
REFERENCES [dbo].user_defined_deal_fields_template (udf_template_id)

GO

