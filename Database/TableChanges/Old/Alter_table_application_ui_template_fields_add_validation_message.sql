IF COL_LENGTH(N'application_ui_template_fields', 'validation_message') IS NULL
BEGIN
	ALTER TABLE application_ui_template_fields 
		ADD validation_message VARCHAR(200) 
		
END


