IF NOT EXISTS(
       SELECT 1
       FROM   INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu
                   ON  tc.TABLE_NAME = ccu.TABLE_NAME
                   AND tc.Constraint_name = ccu.Constraint_name
                   AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                   AND tc.Table_Name = 'maintain_field_template_detail'
                   AND ccu.COLUMN_NAME = 'field_template_id'
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu1
                   ON  tc.TABLE_NAME = ccu1.TABLE_NAME
                   AND tc.Constraint_name = ccu1.Constraint_name
                   AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                   AND tc.Table_Name = 'maintain_field_template_detail'
                   AND ccu1.COLUMN_NAME = 'field_id'
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu2
                   ON  tc.TABLE_NAME = ccu2.TABLE_NAME
                   AND tc.Constraint_name = ccu2.Constraint_name
                   AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                   AND tc.Table_Name = 'maintain_field_template_detail'
                   AND ccu2.COLUMN_NAME = 'udf_or_system'
   )
    ALTER TABLE [dbo].maintain_field_template_detail WITH NOCHECK ADD CONSTRAINT 
    [UC_maintain_field_template_detail_field_template_id] UNIQUE(field_template_id, field_id, udf_or_system)
GO
