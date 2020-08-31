IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'UNIQUE'
                    AND   tc.Table_Name = 'maintain_field_deal'      
                    AND ccu.COLUMN_NAME = 'field_id'      
)
ALTER TABLE [dbo].[maintain_field_deal] WITH NOCHECK ADD CONSTRAINT 
[UC_maintain_field_deal_field_id] UNIQUE(field_id)

GO
IF NOT EXISTS(
       SELECT 1
       FROM   INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu
                   ON  tc.TABLE_NAME = ccu.TABLE_NAME
                   AND tc.Constraint_name = ccu.Constraint_name
                   AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                   AND tc.Table_Name = 'maintain_field_deal'
                   AND ccu.COLUMN_NAME = 'farrms_field_id'
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu1
                   ON  tc.TABLE_NAME = ccu1.TABLE_NAME
                   AND tc.Constraint_name = ccu1.Constraint_name
                   AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                   AND tc.Table_Name = 'maintain_field_deal'
                   AND ccu1.COLUMN_NAME = 'header_detail'
   )
    ALTER TABLE [dbo].maintain_field_deal WITH NOCHECK ADD CONSTRAINT 
    [UC_maintain_field_deal_farrms_field_id] UNIQUE(farrms_field_id, header_detail)

GO

IF NOT EXISTS(
       SELECT 1
       FROM   INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu
                   ON  tc.TABLE_NAME = ccu.TABLE_NAME
                   AND tc.Constraint_name = ccu.Constraint_name
                   AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                   AND tc.Table_Name = 'maintain_field_deal'
                   AND ccu.COLUMN_NAME = 'default_label'
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu1
                   ON  tc.TABLE_NAME = ccu1.TABLE_NAME
                   AND tc.Constraint_name = ccu1.Constraint_name
                   AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                   AND tc.Table_Name = 'maintain_field_deal'
                   AND ccu1.COLUMN_NAME = 'header_detail'
   )
    ALTER TABLE [dbo].maintain_field_deal WITH NOCHECK ADD CONSTRAINT 
    [UC_maintain_field_deal_default_label] UNIQUE(default_label, header_detail)

GO


