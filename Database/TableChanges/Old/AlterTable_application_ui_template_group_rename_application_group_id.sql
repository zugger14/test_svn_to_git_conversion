IF EXISTS(SELECT 1 FROM sys.columns c  INNER JOIN sys.tables t ON 
c.object_id = t.object_id where t.name = 'application_ui_template_group'
AND c.name = 'appliction_group_id')
	EXEC sp_rename 'application_ui_template_group.appliction_group_id','application_group_id','column'
ELSE
	PRINT 'Didnt find the table'
