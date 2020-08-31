IF NOT EXISTS(
       SELECT 1
       FROM   INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu
                   ON  tc.TABLE_NAME = ccu.TABLE_NAME
                   AND tc.Constraint_name = ccu.Constraint_name
                   AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                   AND tc.Table_Name = 'maintain_field_template_group'
                   AND ccu.COLUMN_NAME = 'field_template_id'
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu1
                   ON  tc.TABLE_NAME = ccu1.TABLE_NAME
                   AND tc.Constraint_name = ccu1.Constraint_name
                   AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                   AND tc.Table_Name = 'maintain_field_template_group'
                   AND ccu1.COLUMN_NAME = 'group_name'
   )
    ALTER TABLE [dbo].maintain_field_template_group WITH NOCHECK ADD CONSTRAINT 
    [UC_maintain_field_template_group_field_group_name] UNIQUE(field_template_id, group_name)
GO

IF NOT EXISTS(
       SELECT 1
       FROM   INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu
                   ON  tc.TABLE_NAME = ccu.TABLE_NAME
                   AND tc.Constraint_name = ccu.Constraint_name
                   AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                   AND tc.Table_Name = 'maintain_field_template_group'
                   AND ccu.COLUMN_NAME = 'field_template_id'
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu1
                   ON  tc.TABLE_NAME = ccu1.TABLE_NAME
                   AND tc.Constraint_name = ccu1.Constraint_name
                   AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                   AND tc.Table_Name = 'maintain_field_template_group'
                   AND ccu1.COLUMN_NAME = 'seq_no'
   )
    ALTER TABLE [dbo].maintain_field_template_group WITH NOCHECK ADD CONSTRAINT 
    [UC_maintain_field_template_group_seq_no] UNIQUE(field_template_id, seq_no)
GO    
    
    