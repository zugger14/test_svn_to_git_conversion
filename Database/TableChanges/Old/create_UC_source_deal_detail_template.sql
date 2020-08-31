IF NOT EXISTS(
       SELECT 1
       FROM   INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu
                   ON  tc.TABLE_NAME = ccu.TABLE_NAME
                   AND tc.Constraint_name = ccu.Constraint_name
                   AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                   AND tc.Table_Name = 'source_deal_detail_template'
                   AND ccu.COLUMN_NAME = 'template_id'
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu1
                   ON  tc.TABLE_NAME = ccu1.TABLE_NAME
                   AND tc.Constraint_name = ccu1.Constraint_name
                   AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                   AND tc.Table_Name = 'source_deal_detail_template'
                   AND ccu1.COLUMN_NAME = 'leg'
   )
    ALTER TABLE [dbo].source_deal_detail_template WITH NOCHECK ADD CONSTRAINT 
    [UC_source_deal_detail_template_template_id] UNIQUE(template_id, leg)
GO    
