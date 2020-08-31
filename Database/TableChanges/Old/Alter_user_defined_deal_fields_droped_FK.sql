IF EXISTS (
       SELECT *
       FROM   sys.foreign_keys
       WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[FK_user_defined_deal_fields_user_defined_fields_template]')
              AND parent_object_id = OBJECT_ID(N'[dbo].[user_defined_deal_fields]')
)
BEGIN	
	ALTER TABLE user_defined_deal_fields
	DROP CONSTRAINT FK_user_defined_deal_fields_user_defined_fields_template
	PRINT 'Droped FK_user_defined_deal_fields_user_defined_fields_template'
END
ELSE 
BEGIN
	PRINT 'FK_user_defined_deal_fields_user_defined_fields_template do not exists.'

END
	