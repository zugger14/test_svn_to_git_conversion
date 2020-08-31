IF EXISTS (
       SELECT 1
       FROM   sys.foreign_keys
       WHERE  OBJECT_ID = OBJECT_ID(
                  N'dbo.FK_user_defined_deal_fields_user_defined_deal_fields_template'
              )
              AND parent_object_id = OBJECT_ID(N'dbo.user_defined_deal_fields')
   )
    ALTER TABLE [user_defined_deal_fields]

 DROP CONSTRAINT [FK_user_defined_deal_fields_user_defined_deal_fields_template]
 
