IF NOT EXISTS(SELECT 1 FROM sys.tables t INNER JOIN sys.columns c on c.object_id= t.object_id WHERE c.name = 'num_column' AND t.name = 'application_ui_template_fieldsets')
BEGIN
	ALTER TABLE application_ui_template_fieldsets
	ADD num_column INT NULL DEFAULT 1
END
ELSE
PRINT 'Column Exists'


