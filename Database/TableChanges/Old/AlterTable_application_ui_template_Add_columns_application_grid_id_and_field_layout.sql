IF NOT EXISTS(SELECT 1 FROM sys.tables t INNER JOIN sys.columns c on c.object_id= t.object_id WHERE c.name = 'field_layout' AND t.name = 'application_ui_template_group')
BEGIN
	ALTER TABLE application_ui_template_group
	ADD field_layout VARCHAR(10) NULL DEFAULT '1C'
END
ELSE
PRINT 'Column Exists'


IF NOT EXISTS(SELECT 1 FROM sys.tables t INNER JOIN sys.columns c on c.object_id= t.object_id WHERE c.name = 'application_grid_id' AND t.name = 'application_ui_template_group')
BEGIN
	ALTER TABLE application_ui_template_group
	ADD application_grid_id INT NULL REFERENCES adiha_grid_definition(grid_id)
END
ELSE
PRINT 'Column Exists'

