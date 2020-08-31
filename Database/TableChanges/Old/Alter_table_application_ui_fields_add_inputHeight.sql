IF COL_LENGTH('application_ui_template_fields','inputHeight') IS NULL
BEGIN
	ALTER TABLE application_ui_template_fields
	ADD  inputHeight INT
	PRINT 'Table application_ui_template_fields altered. Column inputHeight Added'
END
ELSE
BEGIN
	PRINT 'inputHeight already exists in the table.'
END