IF COL_LENGTH('application_ui_template_definition', 'char_length') IS NULL
BEGIN
	ALTER TABLE application_ui_template_definition ADD char_length INT NULL
END