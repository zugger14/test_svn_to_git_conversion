IF NOT EXISTS(Select 1 FROM sys.tables t INNER JOIN sys.columns c ON t.object_id = c.object_id  where t.name = 'application_ui_template' AND c.name = 'table_name')
	BEGIN
		ALTER TABLE application_ui_template 
			ADD table_name VARCHAR(200)
	END
ELSE
PRINT 'Column already exists'

