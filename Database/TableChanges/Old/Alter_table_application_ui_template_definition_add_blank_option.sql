IF NOT EXISTS(SELECT 1 FROM sys.columns c INNER JOIN sys.tables t ON t.object_id = c.object_id WHERE t.name = 'application_ui_template_definition'
AND c.name = 'blank_option')
	BEGIN
		ALTER TABLE application_ui_template_definition
		ADD  blank_option CHAR(1)  
		PRINT 'Table application_ui_template_definition altered. Column BLank option Added'
	END
ELSE
	BEGIN
		PRINT 'blank_option already exists in the table.'
	END