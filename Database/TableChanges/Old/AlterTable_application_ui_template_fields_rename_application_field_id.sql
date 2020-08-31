IF EXISTS(SELECT 1 FROM sys.columns c  INNER JOIN sys.tables t ON 
c.object_id = t.object_id where t.name = 'application_ui_template_fields'
AND c.name = 'appliction_field_id')
	EXEC	sp_RENAME 'application_ui_template_fields.appliction_field_id' , 'application_field_id', 'COLUMN'
ELSE
	PRINT 'Didnt find the table'
