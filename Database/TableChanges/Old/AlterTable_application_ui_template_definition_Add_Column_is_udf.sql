IF NOT EXISTS(Select 1 FROM sys.tables t INNER JOIN sys.columns c ON t.object_id = c.object_id  where t.name = 'application_ui_template_definition' AND c.name = 'is_udf')
	BEGIN
		ALTER TABLE application_ui_template_definition
		ADD is_udf CHAR(1) DEFAULT 'n'
	END
ELSE
PRINT 'Column already exists' 

 