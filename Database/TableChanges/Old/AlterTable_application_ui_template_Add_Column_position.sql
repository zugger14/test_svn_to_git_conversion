IF NOT EXISTS(Select 1 FROM sys.tables t INNER JOIN sys.columns c ON t.object_id = c.object_id  where t.name = 'application_ui_template_fields' AND c.name = 'position')
BEGIN
	ALTER TABLE application_ui_template_fields
	ADD position VARCHAR(200)
END
ELSE
PRINT 'Column already exists' 

 