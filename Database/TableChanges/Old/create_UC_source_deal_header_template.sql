IF NOT EXISTS(
       SELECT 1
       FROM   INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu
                   ON  tc.TABLE_NAME = ccu.TABLE_NAME
                   AND tc.Constraint_name = ccu.Constraint_name
                   AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                   AND tc.Table_Name = 'source_deal_header_template'
                   AND ccu.COLUMN_NAME = 'template_name'
   )
    ALTER TABLE [dbo].source_deal_header_template WITH NOCHECK ADD CONSTRAINT 
    [UC_source_deal_header_template_template_name] UNIQUE(template_name)
GO
