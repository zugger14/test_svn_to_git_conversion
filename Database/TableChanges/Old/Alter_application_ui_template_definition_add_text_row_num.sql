IF COL_LENGTH(N'application_ui_template_definition', 'text_row_num') IS NULL
BEGIN
	ALTER TABLE application_ui_template_definition 
		ADD text_row_num INT 
		
END
