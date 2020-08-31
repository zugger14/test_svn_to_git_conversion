IF NOT EXISTS(
       SELECT 1
       FROM   INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu
                   ON  tc.TABLE_NAME = ccu.TABLE_NAME
                   AND tc.Constraint_name = ccu.Constraint_name
                   AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                   AND tc.Table_Name = 'user_defined_deal_fields_template'
                   AND ccu.COLUMN_NAME = 'template_id'
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu1
                   ON  tc.TABLE_NAME = ccu1.TABLE_NAME
                   AND tc.Constraint_name = ccu1.Constraint_name
                   AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                   AND tc.Table_Name = 'user_defined_deal_fields_template'
                   AND ccu1.COLUMN_NAME = 'field_name'
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu2
                   ON  tc.TABLE_NAME = ccu2.TABLE_NAME
                   AND tc.Constraint_name = ccu2.Constraint_name
                   AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                   AND tc.Table_Name = 'user_defined_deal_fields_template'
                   AND ccu2.COLUMN_NAME = 'leg'
   )
    ALTER TABLE [dbo].user_defined_deal_fields_template WITH NOCHECK ADD CONSTRAINT 
    [UC_user_defined_deal_fields_template_field_name] UNIQUE(template_id, field_name, leg)
GO

IF NOT EXISTS(
       SELECT 1
       FROM   INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu
                   ON  tc.TABLE_NAME = ccu.TABLE_NAME
                   AND tc.Constraint_name = ccu.Constraint_name
                   AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                   AND tc.Table_Name = 'user_defined_deal_fields_template'
                   AND ccu.COLUMN_NAME = 'template_id'
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu1
                   ON  tc.TABLE_NAME = ccu1.TABLE_NAME
                   AND tc.Constraint_name = ccu1.Constraint_name
                   AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                   AND tc.Table_Name = 'user_defined_deal_fields_template'
                   AND ccu1.COLUMN_NAME = 'field_id'
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu2
                   ON  tc.TABLE_NAME = ccu2.TABLE_NAME
                   AND tc.Constraint_name = ccu2.Constraint_name
                   AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                   AND tc.Table_Name = 'user_defined_deal_fields_template'
                   AND ccu2.COLUMN_NAME = 'leg'
   )
    ALTER TABLE [dbo].user_defined_deal_fields_template WITH NOCHECK ADD CONSTRAINT 
    [UC_user_defined_deal_fields_template_field_id] UNIQUE(template_id, field_id, leg)
GO
