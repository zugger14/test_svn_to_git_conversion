IF NOT EXISTS(
       SELECT 1
       FROM   INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu
                   ON  tc.TABLE_NAME = ccu.TABLE_NAME
                   AND tc.Constraint_name = ccu.Constraint_name
                   AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                   AND tc.Table_Name = 'user_defined_deal_fields'
                   AND ccu.COLUMN_NAME = 'source_deal_header_id'
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu1
                   ON  tc.TABLE_NAME = ccu1.TABLE_NAME
                   AND tc.Constraint_name = ccu1.Constraint_name
                   AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                   AND tc.Table_Name = 'user_defined_deal_fields'
                   AND ccu1.COLUMN_NAME = 'udf_template_id'
   )
    ALTER TABLE [dbo].user_defined_deal_fields WITH NOCHECK ADD CONSTRAINT 
    [UC_user_defined_deal_fields_source_deal_header_id] UNIQUE(source_deal_header_id, udf_template_id)
    
GO
