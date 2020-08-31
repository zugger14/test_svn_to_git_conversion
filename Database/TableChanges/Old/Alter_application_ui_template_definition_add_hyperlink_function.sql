IF COL_LENGTH(N'application_ui_template_definition', 'hyperlink_function') IS NULL
BEGIN
	ALTER TABLE application_ui_template_definition 
		ADD hyperlink_function VARCHAR(200) 
		
END
